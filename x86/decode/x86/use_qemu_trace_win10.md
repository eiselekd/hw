# Windows 10 Instruction Census via QEMU — Plan

Goal: extend the ISA census + encoding-corpus pipeline ([plan.md](plan.md)) to a
**Windows 10 boot**, producing the same artifacts we have for win98/winnt:

```
x86/win10/traces/win10.boot*.tsv                          opcode histogram (form 1)
x86/win10/instructions/win10.hist.tsv, coverage.md, ...   aggregated census
x86/win10/instructions/decoded_database/win10.corpus.jsonl  encoding-shape corpus
x86/win10/instructions/decoded_database/win10.decoded.*     iced-cross-checked DB
```

## Why not v86

The collector used for win98/winnt cannot run Win10; this is structural, not
configuration:

1. **No long mode** — v86 is 32-bit only, so x64 Win10 is out entirely.
2. **No NX** — 32-bit Win10 hard-requires PAE + NX + SSE2 at kernel entry.
   v86 has PAE paging and advertises SSE2, but implements no `IA32_EFER`
   (`0xC0000080`) MSR at all, and its CPUID has no leaf `0x8000_0001` to
   advertise XD. The Win8+ loader refuses to start.
3. **Scale** — the win98 boot was 8.8 G insns; Win10 is O(10^10..10^11), plus
   Win10 needs ≥1 GB RAM, a ~32 GB disk and real ACPI.

**Chosen collector: QEMU TCG plugin** — already prototyped as the cross-check
[tools/qemu_plugin_hist.c](tools/qemu_plugin_hist.c). QEMU boots Win10 under
TCG in tens of minutes, and the plugin API gives per-insn translation/exec
callbacks without patching the emulator. Bochs instrumentation stays as the
independent cross-check (slow: many hours per boot).

## Up-front decisions

| decision | choice | rationale |
|---|---|---|
| guest bitness | **32-bit Win10 (22H2) first**, x64 as Phase 5 | no long mode → no REX/RIP-rel dimension; decode_db.py and the l8 side stay close to the existing 386 decoder |
| firmware | **legacy BIOS (SeaBIOS) + MBR install** | keeps the 16-bit real-mode / SeaBIOS phase comparable with the existing corpora; avoids OVMF/UEFI 64-bit DXE noise |
| CPU model | `-cpu Nehalem` (32-bit guest can also try `-cpu qemu32,+pae,+nx,+sse2,+sse3`) | oldest model Win10 accepts; **no AVX** so the guest cannot light up wide-vector paths — keeps the census minimal |
| SMP | `-smp 1` | one vcpu ⇒ no cross-CPU merging in the plugin; Win10 boots fine uniprocessor |
| QEMU version | **pin ≥ 9.0** | scoreboard + inline counter ops + `qemu_plugin_get_registers` are all stable there |
| image | user-supplied ISO (licensed) — `fetch_image.sh` N/A; everything under `x86/win10/images/` gitignored | |

## Phase 0 — target scaffolding

- `mkdir x86/win10/{images,traces,instructions,shots}` (mirror win98/winnt).
- Add a `win10` entry to [targets.json](targets.json) with a new
  `"collector": "qemu"` field (absent = v86, so existing targets are
  untouched); fields: `memory: 2048`, `disk_gb: 32`, `cpu: "Nehalem"`,
  `boot_seconds`, `phase_every`, `shots`, and a `login` script if the install
  gets a password.
- **Install once under KVM** (fast, untraced): local-account, no-network OOBE
  (`OOBE\BYPASSNRO`), disable Defender scheduled scans + Windows Update via
  `unattend.xml` or post-install, so the traced boot is quiet and repeatable.
  Then snapshot the disk (`qcow2` backing file) — every traced run starts from
  the identical cold-boot state.
- Driver script: extend [tools/run.sh](tools/run.sh) to branch on
  `collector == "qemu"`; screenshots and login keystrokes go through QMP
  (`screendump`, `sendkey`) instead of screenshot.mjs — small
  `tools/qemu_drive.mjs` (or python) reading the same `shots`/`login` fields.

## Phase 1 — histogram census (WHICH instructions)

Upgrade `qemu_plugin_hist.c`. Current gaps, in priority order:

- **W1 — real mode detection.** Today the plugin *guesses* 16/32 from `0x66`
  (`/* mode from tb is not exposed */`) and has no 64-bit notion at all.
  Options:
  - (a) parse `qemu_plugin_insn_disas()` — QEMU translated the TB with the
    true mode, so the disassembly string is mode-correct and gives us the
    mnemonic for free (fills the `?` mnemonic column, and replaces the coarse
    `op_has_modrm()` heuristic as a cross-check);
  - (b) `qemu_plugin_get_registers()` at exec time (read `cs`/`eflags`, and
    `efer` where exposed) — heavier;
  - (c) last resort: 3-line QEMU patch exporting `tb->flags` mode bits.
  Start with (a); keep (b) as verification on a sample of TBs.
- **W2 — key widening.** u32 key → **u64**:
  `mode(16/32/64) | map(none/0F/0F38/0F3A) | mandatory-prefix(none/66/F2/F3) |
  opcode | modrm-ext`. For the 0F map, `66/F2/F3` are *opcode selectors*, not
  skippable prefixes — the current prefix loop folds e.g. `MOVSD` and `MOVUPS`
  into one bucket.
- **W3 — proper modrm table.** Replace `op_has_modrm()` with the table already
  derived from ref.x86asm.net for [tools/annotate.py](tools/annotate.py)
  (generate a C header from it).
- **W4 — cheap counting.** The per-insn mutexed hash bump is fine at 10^9
  insns, not at 10^10..10^11. Use
  `qemu_plugin_register_vcpu_insn_exec_inline_per_vcpu(... INLINE_ADD_U64 ...)`
  on a per-key scoreboard slot allocated at translation time; exec path
  becomes one inline add, all aggregation happens at dump time.
- **W5 — phase dumps.** Dump the histogram every `phase_every` seconds
  (glib timer) and on SIGUSR1, like the Bochs collector, →
  `win10.boot.phaseN.tsv`. Dumps are cumulative, matching the existing
  aggregation convention.

Run recipe (traced, TCG):

```sh
qemu-system-i386 -accel tcg -cpu Nehalem -smp 1 -m 2048 \
    -drive file=win10/images/win10-32.qcow2,if=ide \
    -plugin tools/qemu_plugin_hist.so,out=win10/traces/win10.boot.tsv,phase=60 \
    -qmp unix:/tmp/win10.qmp,server,nowait -display none -vga std
```

Then the existing tail of the pipeline unchanged:
`aggregate.py traces/*.tsv -o instructions/win10.hist.tsv --coverage ...`,
`annotate.py`, and a win98/winnt/win10 section in [COMPARISON.md](COMPARISON.md).

### Gate G1 — validate the plugin against the known-good census

Before trusting any win10 numbers: **boot win98.img under QEMU with the
upgraded plugin** and diff the aggregated opcode *set* (not counts — different
BIOS/timing) against the v86 census. Every encoding v86 saw must appear, and
new ones must be explainable (SeaBIOS vs v86 BIOS, `-cpu` differences). This
reuses an image and a ground truth we already have.

## Phase 2 — encoding corpus (l8trace equivalent)

New plugin `tools/qemu_plugin_l8corpus.c` (histogram plugin stays separate and
simple), emitting the **same JSONL the v86 `l8trace` feature produces** so
[tools/decode_db.py](tools/decode_db.py) consumes it unchanged:

```json
{"mode":32, "hdr":<n-steering-bytes>, "count":N, "bytes":["<=16B sample", "..."], "phase":P}
```

- Shape key = mode + every byte that *steers* decode (prefix run, escapes,
  opcode, modrm, SIB), computed at **translation time** from
  `qemu_plugin_insn_data()` (16 bytes — sufficient). Displacements/immediates
  excluded from the key, ≤2 full-byte samples kept per shape — identical
  policy to v86's l8trace.
- Dedup hash lives in the plugin; exec-time cost is again one inline counter
  add per shape. A 10^10-insn boot stays a ~1 MB file.
- `decode_db.py`: for the 32-bit guest it should work nearly as-is (new SSE
  shapes exercise the existing positional decoder; iced-x86 side unchanged).
  Extend the shape-`hdr` logic for mandatory-prefix opcodes if the positional
  decode disagrees with iced on length.
- Output → `win10/instructions/decoded_database/`, failure registry
  `win10.l8_failures.jsonl`, same as winnt.

Gate G2: `decode_db.py --clean` runs green (positional decode == iced-x86) on
the full win10 corpus.

## Phase 3 — cross-checks

- **Bochs** (`--enable-cpu-level=6`, existing
  [tools/bochs_instrument.cc](tools/bochs_instrument.cc) needs the same W2 key
  widening): one overnight run, diff opcode sets against the QEMU census.
- Optional determinism: `-icount shift=auto,sleep=off` makes reruns
  byte-identical at ~2x slowdown; nice-to-have, not required since we census
  shapes, not counts.

## Phase 4 — l8 decoder scope (side B)

The census will land outside `decode_x86_limited.l8` (386 subset). Expected
new families for 32-bit Win10, roughly in frequency order: SSE/SSE2 moves and
ALU (mandatory-prefix dimension on the 0F map), `0F 1F` long NOP, `CMPXCHG8B`,
`FXSAVE/FXRSTOR`, `SYSENTER/SYSEXIT`, fences (`0F AE /5..7`), `PAUSE`
(`F3 90`), prefetches, `RDTSCP`, possibly `XSAVE` family depending on `-cpu`.

Decision for that phase: extend `decode_x86_limited.l8` vs. a layered
`decode_x86_sse.l8`. Either way the acceptance is the existing sweep:
`make l8verify` over the win10 corpus with zero unexplained failures.

## Phase 5 (stretch) — Win10 x64

Same pipeline, `qemu-system-x86_64`. New work concentrates in three places:
mode 64 in both plugins (REX in the shape key, RIP-relative disp32), mode 64
in `decode_db.py`'s positional decoder (iced already does 64-bit), and a long-
mode story for the l8 decoder. Do not start until G1/G2 are green for 32-bit.

## Risks / practicalities

| risk | mitigation |
|---|---|
| TCG wall-clock: 10^10+ insns at a few hundred MIPS effective | inline counters (W4); install under KVM, trace only the boot; expect 1–3 h per traced run |
| Win10 background noise (Update, Defender, telemetry) makes runs incomparable | debloat at install time; no network (`-nic none`) during traced boots |
| plugin decode bugs corrupt the census silently | Gate G1 (win98 replay) + `insn_disas` mnemonic cross-check per TB |
| mode detection wrong on 16↔32 transitions (V86 mode, boot) | verify real-mode phase against `seabios-post.tsv` from the win98 work |
| image licensing | user-supplied ISO; `x86/win10/images/` gitignored, nothing redistributed |

## Milestones

- **M1** — Phase 0 done: installed, debloated, snapshotted 32-bit Win10 image
  boots to desktop under plain TCG (no plugin) in bounded time.
- **M2** — upgraded histogram plugin passes Gate G1 (win98-under-QEMU set-diff
  vs v86 census explained).
- **M3** — first full win10 census: `win10.hist.tsv`, `coverage.md`,
  COMPARISON.md row; headline number = distinct encodings vs win98's 688.
- **M4** — corpus plugin + `decode_db.py` pass Gate G2; decoded database
  committed.
- **M5** — l8 decoder extended; `make l8verify` green on the win10 corpus.
- **M6** (stretch) — x64 repeat of M3/M4.
