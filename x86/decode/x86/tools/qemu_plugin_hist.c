/*
 * QEMU TCG plugin: per-opcode execution histogram (no emulator patching).
 *
 * Build (against a qemu source tree, >= 6.0):
 *   gcc -fPIC -shared -o qemu_plugin_hist.so qemu_plugin_hist.c \
 *       -I<qemu>/include/qemu -I<qemu>/build
 *
 * Run:
 *   qemu-system-i386 -plugin ./qemu_plugin_hist.so,out=win98.hist.tsv \
 *       -d plugin -hda win98.img -m 64 -cpu pentium2
 *
 * Output is aggregate.py "form 1" TSV.  Note QEMU gives us the instruction
 * bytes, so we decode just enough (prefixes, 0F escape, modrm) ourselves.
 */
#include <glib.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <qemu-plugin.h>

QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;

static GHashTable *hist;      /* key: packed u32 -> count (u64*) */
static GMutex lock;
static char *outfile = "win98.hist.tsv";

/* key layout: [31:24] mode(16/32) [23:8] opcode (0x100|b for 0F) [7:0] ext+1 */
static inline uint32_t mk_key(int mode, int opcode, int ext)
{
    return ((uint32_t)(mode == 32) << 24) | ((uint32_t)opcode << 8) | (uint8_t)(ext + 1);
}

static int op_has_modrm(int opcode)
{
    /* Coarse but sufficient: refine from x86/decoders tables once available. */
    if (opcode >= 0x100) return 1;                    /* most 0F ops do */
    if (opcode < 0x40) return (opcode & 7) < 4;       /* alu r/m forms */
    if (opcode >= 0x88 && opcode <= 0x8F) return 1;
    if (opcode >= 0xC0 && opcode <= 0xC1) return 1;
    if (opcode >= 0xD0 && opcode <= 0xD3) return 1;
    if (opcode >= 0xF6 && opcode <= 0xF7) return 1;
    if (opcode >= 0xFE && opcode <= 0xFF) return 1;
    if (opcode == 0x62 || opcode == 0x63 || opcode == 0x69 || opcode == 0x6B) return 1;
    if (opcode >= 0x80 && opcode <= 0x83) return 1;
    if (opcode == 0xC4 || opcode == 0xC5 || opcode == 0xC6 || opcode == 0xC7) return 1;
    if (opcode >= 0xD8 && opcode <= 0xDF) return 1;   /* x87 */
    return 0;
}

static void vcpu_insn_exec(unsigned int cpu_index, void *udata)
{
    uint32_t key = (uint32_t)(uintptr_t)udata;
    g_mutex_lock(&lock);
    uint64_t *c = g_hash_table_lookup(hist, GUINT_TO_POINTER(key));
    if (!c) { c = g_new0(uint64_t, 1); g_hash_table_insert(hist, GUINT_TO_POINTER(key), c); }
    (*c)++;
    g_mutex_unlock(&lock);
}

static void vcpu_tb_trans(qemu_plugin_id_t id, struct qemu_plugin_tb *tb)
{
    size_t n = qemu_plugin_tb_n_insns(tb);
    for (size_t i = 0; i < n; i++) {
        struct qemu_plugin_insn *insn = qemu_plugin_tb_get_insn(tb, i);
        uint8_t buf[16] = {0};
        size_t len = qemu_plugin_insn_data(insn, buf, sizeof(buf));

        size_t p = 0;
        int opsize32 = 1;                 /* refined by 0x66 below; mode from tb is not exposed */
        while (p < len) {                 /* skip legacy prefixes */
            uint8_t b = buf[p];
            if (b == 0x66) { opsize32 = !opsize32; p++; continue; }
            if (b == 0x67 || b == 0xF0 || b == 0xF2 || b == 0xF3 ||
                b == 0x2E || b == 0x36 || b == 0x3E || b == 0x26 ||
                b == 0x64 || b == 0x65) { p++; continue; }
            break;
        }
        if (p >= len) continue;
        int opcode = buf[p++];
        if (opcode == 0x0F && p < len) opcode = 0x100 | buf[p++];
        int ext = -1;
        if (op_has_modrm(opcode) && p < len) ext = (buf[p] >> 3) & 7;

        uint32_t key = mk_key(opsize32 ? 32 : 16, opcode, ext);
        qemu_plugin_register_vcpu_insn_exec_cb(insn, vcpu_insn_exec,
                                               QEMU_PLUGIN_CB_NO_REGS,
                                               (void *)(uintptr_t)key);
    }
}

static void plugin_exit(qemu_plugin_id_t id, void *p)
{
    FILE *f = fopen(outfile, "w");
    if (!f) return;
    fprintf(f, "#count\tmode\topcode\text\tmnemonic\n");
    GHashTableIter it; gpointer k, v;
    g_hash_table_iter_init(&it, hist);
    while (g_hash_table_iter_next(&it, &k, &v)) {
        uint32_t key = GPOINTER_TO_UINT(k);
        int mode = (key >> 24) ? 32 : 16;
        int opcode = (key >> 8) & 0xFFFF;
        int ext = (int)(key & 0xFF) - 1;
        char op[8];
        if (opcode >= 0x100) snprintf(op, sizeof op, "0F %02X", opcode & 0xFF);
        else                 snprintf(op, sizeof op, "%02X", opcode);
        fprintf(f, "%" PRIu64 "\t%d\t%s\t", *(uint64_t *)v, mode, op);
        if (ext >= 0) fprintf(f, "/%d\t?\n", ext); else fprintf(f, "-\t?\n");
    }
    fclose(f);
}

QEMU_PLUGIN_EXPORT int qemu_plugin_install(qemu_plugin_id_t id,
                                           const qemu_info_t *info,
                                           int argc, char **argv)
{
    for (int i = 0; i < argc; i++)
        if (g_str_has_prefix(argv[i], "out=")) outfile = g_strdup(argv[i] + 4);

    hist = g_hash_table_new_full(NULL, NULL, NULL, g_free);
    qemu_plugin_register_vcpu_tb_trans_cb(id, vcpu_tb_trans);
    qemu_plugin_register_atexit_cb(id, plugin_exit, NULL);
    return 0;
}
