// Bochs instrumentation stub -- x86/win98/tools/bochs_instrument.cc
//
// Build:
//   ./configure --enable-instrumentation="instrument/win98" --enable-x86-debugger \
//               --enable-cpu-level=6 --enable-pci --enable-vbe --enable-clgd54xx
//   copy this file over instrument/win98/instrument.cc (keep the header)
//   make && ./bochs -q -f win98.bxrc
//
// Emits a counted histogram, not a trace: a full Win98 boot is ~10^10 insns.
// Dump with SIGUSR1 (kill -USR1 <pid>) or at exit -> /tmp/win98.hist.tsv,
// consumable by aggregate.py (form 1).

#include "bochs.h"
#include "cpu/cpu.h"
#include <csignal>
#include <cstdio>
#include <map>
#include <string>

#if BX_INSTRUMENTATION

namespace {

struct Key {
    unsigned mode;          // 16 or 32
    unsigned opcode;        // 0x100 | b for 0F-escaped
    int      ext;           // reg field of modrm, or -1
    bool operator<(const Key& o) const {
        return mode != o.mode ? mode < o.mode
             : opcode != o.opcode ? opcode < o.opcode
             : ext < o.ext;
    }
};

std::map<Key, unsigned long long> g_hist;
volatile sig_atomic_t g_dump_requested = 0;

void on_usr1(int) { g_dump_requested = 1; }

} // namespace

void bx_instr_initialize(unsigned /*cpu*/) { signal(SIGUSR1, on_usr1); }

void bx_instr_before_execution(unsigned /*cpu*/, bxInstruction_c* i)
{
    Key k;
    k.mode   = i->os32L() ? 32 : 16;
    k.opcode = i->b1();                       // already includes 0x100.. for 0F
    k.ext    = i->modC0() || true ? (int)i->nnn() : -1;
    g_hist[k]++;

    if (g_dump_requested) { g_dump_requested = 0; bx_instr_dump_histogram(); }
}

void bx_instr_dump_histogram()
{
    FILE* f = fopen("/tmp/win98.hist.tsv", "w");
    if (!f) return;
    fprintf(f, "#count\tmode\topcode\text\tmnemonic\n");
    for (const auto& e : g_hist) {
        const Key& k = e.first;
        char op[8];
        if (k.opcode >= 0x100) snprintf(op, sizeof op, "0F %02X", k.opcode & 0xFF);
        else                   snprintf(op, sizeof op, "%02X", k.opcode);
        if (k.ext >= 0) fprintf(f, "%llu\t%u\t%s\t/%d\t?\n", e.second, k.mode, op, k.ext);
        else            fprintf(f, "%llu\t%u\t%s\t-\t?\n",   e.second, k.mode, op);
    }
    fclose(f);
}

void bx_instr_exit(unsigned /*cpu*/) { bx_instr_dump_histogram(); }

#endif // BX_INSTRUMENTATION
