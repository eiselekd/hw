# x86 (32-bit) Instruction Decode Gathering — Plan

Goal: produce a machine-readable, text-based description of the **encoding layout** of the
subset of IA-32 instructions that is sufficient to boot Windows 98.

The work is split into two independent halves that meet in the middle:

```
 (A) WHICH instructions?            (B) HOW are they encoded?
  boot Win98 in an emulator     +    scrape/convert existing decoder tables
  instrument the decoder             from several projects
  -> frequency histogram             -> normalized layout list
                    \              /
                     -> x86/win98/instructions/win98.isa.md (+ .json)
```

---

## Phase 0 — Repository layout

```
x86/
  plan.md                     <- this file
  decoders/                   <- vendored / referenced 3rd-party decoders (one dir each)
    README.md                 <- catalogue + licence notes
  win98/
    tools/                    <- instrumentation + aggregation utilities
    traces/                   <- raw trace output (gitignored, can be huge)
    instructions/             <- final histograms + instruction set definition
```

## Phase 1 — Determine the instruction set actually used by a Win98 boot

### 1.1 Choose an instrumentable emulator

| Candidate | Language | Why | Instrumentation point |
|---|---|---|---|
| **v86 (copy/v86)** | JS + Rust/WASM | runs Win98 *in the browser*, well known good config | `opstats`-style counters in the Rust core |
| **jslinux / PCjs** | JS | PCjs has a full opcode table in JS, easy to hook | `x86ops.js` function table |
| **Bochs** | C++ | `--enable-instrumentation` is a first-class feature | `instrument.cc` `bx_instr_before_execution` |
| **QEMU + plugin API** | C | `qemu-plugin` gives per-insn callbacks, fast | `qemu_plugin_register_vcpu_insn_exec_cb` |

**Chosen and implemented: v86.** It is the project that actually boots Win98 in
a browser, and it already has scaffolding (`src/rust/opstats.rs`) for per-opcode
counters. Two problems with using `opstats` as-is:

1. it only counts instructions that run inside **JIT-compiled** blocks, so cold
   ring-0 code (`LGDT`, `MOV CR0`, `INVLPG`) — exactly what we most need — is
   invisible;
2. its group-opcode list omits `0F 00`, `0F 01`, `0F 18`, `8F`, `C6`, `C7`, and
   `0F 01` is where `LGDT`/`LIDT`/`LMSW`/`INVLPG` live.

So `x86/decoders/v86` carries a `win98stats` cargo feature that counts the
interpreter path *and* the JIT path, with a wider group-opcode list derived from
ref.x86asm.net. See [win98/tools/README.md](win98/tools/README.md).

Status: **complete.** Booting the demo's own Win98 image (fetched from
`i.copy.sh/windows98/` by [win98/tools/fetch_image.sh](win98/tools/fetch_image.sh))
from power-on to the idle GUI yields **8,849,650,841 instructions across 688
distinct encodings, 0 unresolved**. Results and analysis:
[win98/instructions/README.md](win98/instructions/README.md).

Key finding: a **80386 covers all but seven encodings** (RDTSC, XADD, CPUID,
WBINVD, FXSAVE/FXRSTOR). No MMX, no SSE, no CMPXCHG8B. Meanwhile `LTR`, `LLDT`,
`MOV DRn` and `WBINVD` each executed once or twice — which is why the filter must
be "executed at least once".

Bochs and the QEMU TCG plugin are kept as independent cross-checks
([win98/tools/bochs_instrument.cc](win98/tools/bochs_instrument.cc),
[win98/tools/qemu_plugin_hist.c](win98/tools/qemu_plugin_hist.c)).

### 1.2 Instrumentation output format

Every executed instruction emits one line (or is counted in-process):

```
<cs_mode>\t<mnemonic>\t<opcode-bytes-hex>\t<modrm?>\t<eip>
16	mov	B8	-	0x0000FFF0
32	0f_af	0FAF	C1	0x8004A122
```

In-process counting into a hash map is strongly preferred (a full Win98 boot is
~10^10 instructions; a text trace is not viable). Dump the map at snapshot time.

### 1.3 Boot phases to cover (each gets its own histogram)

1. BIOS POST (16-bit real mode)
2. MBR / bootsector, IO.SYS, real-mode DOS
3. Protected-mode switch, VMM32 loader (16→32 bit)
4. Kernel + driver init (32-bit, ring0)
5. GUI up to desktop idle
6. A few user actions (open Explorer, shutdown)

`census_node.mjs --phase-every N --screen` snapshots on a timer and logs every
VGA mode change, so the stages are identifiable: text mode through ~39 s, then
`640x480 4bpp graphical` at ~55 s when the GUI comes up.

Stages 1–5 are covered. Stage 6 (user actions) is still to do — it needs
synthetic keyboard/mouse input via `emulator.keyboard_send_scancodes`.

### 1.4 Deliverables of Phase 1

- `x86/win98/instructions/win98.hist.tsv` — `count \t opcode \t mnemonic \t mode`
- `x86/win98/instructions/win98.opcodes.txt` — de-duplicated required opcode list
- coverage statement: "top N opcodes cover 99.9 % of executed instructions"

## Phase 2 — Gather encoding layouts for that set

### 2.1 Sources to mine (put each under `x86/decoders/<name>/`)

| Source | Form of the data | Notes |
|---|---|---|
| **x86-csv / Intel XED datafiles** | CSV / `xed` `.txt` ISA files | most complete, machine readable |
| **XED (`intelxed/xed`)** | `datafiles/*/*-isa.txt` | ~ the gold standard grammar |
| **Capstone / LLVM `X86.td`** | TableGen | full operand/encoding info |
| **v86 `gen/x86_table.js`** | JS table | *the JS decode project asked for* |
| **PCjs `x86ops.js` / `x86modb.js`** | JS | very readable per-opcode |
| **8086tiny / fake86 tables** | C arrays | 16-bit only |
| **NASM `insns.dat`** | text, encoding column | assembler view, easy to parse |
| **`ref.x86asm.net` (x86asm XML)** | XML `x86reference.xml` | single-file, complete opcode map |
| **Zydis `Generated/` tables** | C / json | decoder-oriented |
| **AMD/Intel SDM Vol.2 appendix A** | PDF | authoritative fallback |

Best "one file, easy to parse" starting point: **x86reference.xml** (ref.x86asm.net)
plus **NASM insns.dat**; best "JS project to read the source of": **v86 gen/x86_table.js**.

### 2.2 Normalized output schema

One record per encoding:

```json
{
  "mnemonic": "ADD",
  "prefixes": ["66", "67", "F2", "F3", "2E.."],
  "opcode": ["01"],           /* escape bytes included: ["0F","AF"] */
  "opcode_ext": null,          /* /r or /0../7 */
  "modrm": true,
  "operands": [{"kind":"rm","size":"v"},{"kind":"reg","size":"v"}],
  "imm": null,                 /* ib | iw | id | cd | ptr16:32 */
  "flags_w": "OSZAPC",
  "modes": ["16","32"],
  "sources": ["xed","nasm","x86asm.net","v86"]
}
```

Textual one-line form for humans, in `layouts.txt`:

```
01 /r        ADD  rm16/32, r16/32   modrm  -    OSZAPC
0F AF /r     IMUL r16/32, rm16/32   modrm  -    OF,CF
C7 /0 id     MOV  rm16/32, imm16/32 modrm  imm  -
```

### 2.3 Cross-validation

- Convert each source into the schema above with a per-source converter in
  `x86/decoders/<name>/to_schema.py`.
- Diff the sources; disagreements are reported into `x86/decoders/DIFF.md`.
- Round-trip check: assemble each encoding with NASM, decode with objdump/Capstone,
  compare mnemonic + operands.

## Phase 3 — Emit the final artifact

- `x86/win98/instructions/win98.isa.json` — the filtered, validated encoding set
- `x86/win98/instructions/win98.isa.txt` — the human readable layout list
- optional: a generated decoder skeleton (switch tree / trie) from that JSON.

## Milestones

| # | Deliverable | Status |
|---|---|---|
| M1 | catalogue of decoders in `x86/decoders/README.md` | done |
| M2 | instrumented emulator (v86 `win98stats`) | done |
| M3 | histogram from a real Win98 boot | **done**, 688 encodings |
| M4 | one source converted to the schema (ref.x86asm.net) | done, `annotate.py` |
| M5 | all sources converted + diffed | todo |
| M6 | final filtered ISA file | M5 |

## Next step

Phase 1 is finished; the required instruction set is in
[win98/instructions/win98.isa.json](win98/instructions/win98.isa.json).

Phase 2 is now the open work: convert the remaining decoders in
`x86/decoders/` (XED, NASM `insns.dat`, udis86 `optable.xml`, Zydis,
v86's own `gen/x86_table.js`) into the schema in §2.2 and diff them against each
other and against what we already have from ref.x86asm.net. The 688-encoding
list is the filter that keeps that job small.

Also still open:
- stage 6 above (user actions) via synthetic input;
- a second boot on different emulated hardware, to see how much the driver set
  changes the tail;
- cross-check the census itself with the Bochs or QEMU collector.

## Open questions

- ~~Target CPU baseline: 486 vs Pentium~~ **Answered by the census:** booting to
  the desktop needs a 386 plus exactly RDTSC, XADD, CPUID, WBINVD and
  FXSAVE/FXRSTOR. x87 is used (22 encodings) but MMX/SSE/CMPXCHG8B are not.
  Win98 *setup* is a separate question and is not covered.
- Ring0-only system instructions (LGDT, LTR, MOV CRn/DRn, INVLPG, IRETD, HLT)
  must be included even though their frequency is tiny — confirmed: `LTR` and
  `WBINVD` execute exactly once each in a whole boot. Filter is "used at least
  once", not "used often".
- How much does the tail depend on emulated hardware? Needs a second boot with a
  different device set to answer.
