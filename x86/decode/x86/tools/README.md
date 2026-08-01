# Win98 instruction-census tooling

Answers Phase 1 of [../../plan.md](../../plan.md): **which** x86 instructions does
a Windows 98 boot actually execute, and how often.

The census is produced by an instrumented build of
[copy/v86](https://github.com/copy/v86) — the JS/WASM PC emulator that can boot
Win98 in a browser. v86 already ships an `opstats` profiler, but it only counts
instructions running inside *JIT-compiled* blocks, and it has no 16/32-bit code
segment bit. For an ISA census the opposite bias matters: an instruction like
`LGDT` or `MOV CR0, eax` executes a handful of times during the protected-mode
switch and never gets hot enough to be compiled — yet it is absolutely required.

So `x86/decoders/v86` carries a small patch adding a `win98stats` cargo feature
that counts **both** the interpreter path and the JIT path.

| file | role |
|---|---|
| [fetch_image.sh](fetch_image.sh) | download the **exact disk image the copy.sh/v86 demo uses** and reassemble it |
| [census_node.mjs](census_node.mjs) | headless driver: boots an image under node and writes the census TSV |
| [v86_census.js](v86_census.js) | `Win98Census` class — reads the wasm counters; works in the browser too |
| [aggregate.py](aggregate.py) | merge several censuses/traces, coverage table, opcode list |
| [annotate.py](annotate.py) | join the census against ref.x86asm.net → mnemonics + encoding layouts |
| [bochs_instrument.cc](bochs_instrument.cc) | alternative collector: Bochs `--enable-instrumentation` |
| [qemu_plugin_hist.c](qemu_plugin_hist.c) | alternative collector: QEMU TCG plugin, no emulator patching |

## The v86 patch

Applied to `x86/decoders/v86` (see `git -C x86/decoders/v86 diff`):

| file | change |
|---|---|
| `src/rust/win98stats.rs` | new: 16 K counter buffer, prefix histogram, wasm exports |
| `src/rust/lib.rs` | `pub mod win98stats;` |
| `src/rust/cpu/cpu.rs` | `record_interpreted()` in `jit_run_interpreted`'s loop |
| `src/rust/jit.rs` | `gen_record_compiled()` emits an inline `i64.add` per instruction |
| `Cargo.toml` | `win98stats` feature |
| `Makefile` | `with-win98stats` target |

Counter index layout (16384 entries):

```
is_32 << 13 | is_0f << 12 | opcode << 4 | is_mem << 3 | fixed_g
```

`fixed_g` (the modrm reg field used as an opcode extension) is recorded for the
group opcodes listed in `has_fixed_g()`, derived from ref.x86asm.net's
`<opcd_ext>` entries. This deliberately covers **more** than v86's own
`opstats::decode`, which omits `0F 00`, `0F 01`, `0F 18`, `8F`, `C6` and `C7` —
and `0F 01` is precisely where `LGDT`/`LIDT`/`LMSW`/`INVLPG` live.

## Build

```sh
cd x86/decoders/v86
make with-win98stats          # release wasm with the counters
make build/libv86-debug.mjs   # JS library (needs java, downloads closure)
```

Prerequisites: `rustup target add wasm32-unknown-unknown`, a `clang` able to
target `wasm32`, `node`, `java`.

## Get the image

We use the **same image the hosted demo boots**. v86 serves it as 1200 fixed
256 KB parts (`https://i.copy.sh/windows98/<offset>-<offset+262144>.img`, see
`AsyncXHRPartfileBuffer` in `v86/src/buffer.js`); the browser pulls only the
chunks it touches, but for repeated headless runs it is far better to reassemble
it once:

```sh
./fetch_image.sh windows98          # -> ../images/windows98.img  (300 MB, ~30 s)
./fetch_image.sh windows98 state    # also the boot-to-desktop snapshot
```

The result is a real MS-DOS 7.1 / Win98 FAT16 disk:

```
windows98.img1 *  63  613871  613809  299.7M  e  W95 FAT16 (LBA)
```

`fetch_image.sh` also knows `windows95`; sizes come from the profile table in
`v86/src/browser/main.js`.

## Collect

`--profile` reproduces the demo's own configuration (memory size and image), so
the census matches what "Windows 98 in the browser" actually executes:

```sh
./census_node.mjs --profile windows98-boot \
    --seconds 600 --phase-every 120 --screen \
    --out ../traces/win98.boot.tsv
```

| profile | meaning |
|---|---|
| `windows98-boot` | cold boot from power-on — **use this for a boot census** |
| `windows98` | same, but `--state` can resume the demo's boot-to-desktop snapshot |
| `windows95` | Win95 image |

Useful flags: `--phase-every N` snapshots every N seconds so the boot stages
(BIOS POST → real-mode DOS → protected-mode switch → VMM32 → GUI) can be
separated; `--screen` prints the text-mode screen and logs every VGA mode change,
which is how you tell the GUI came up:

```
[screen] 80x25 text @ 39s
[screen] 640x480 4bpp graphical @ 55s
```

`SIGINT` also dumps and exits. Add `--verbose` to see v86's debug log. Explicit
`--hda/--cdrom/--fda/--memory` override the profile.

In the browser (your own page built with the `win98stats` wasm):

```js
const c = new Win98Census(emulator.v86.cpu);
c.clear();
// ... boot ...
c.phase("phase3.pmode");   // downloads a TSV and resets for the next phase
```

## Aggregate and annotate

```sh
./aggregate.py ../traces/*.tsv \
    -o ../instructions/win98.hist.tsv \
    --coverage ../instructions/win98.coverage.md \
    --opcodes  ../instructions/win98.opcodes.txt

./annotate.py ../instructions/win98.hist.tsv \
    -o     ../instructions/win98.isa.txt \
    --json ../instructions/win98.isa.json
```

`annotate.py` needs `x86/decoders/x86asm-net/x86reference.xml`
(`x86/decoders/fetch.sh x86asm-net`). It expands the "register in opcode"
(`+r`) ranges that the reference only lists at the base opcode — `50` covers
`50..57` PUSH, `58` covers POP, `B8` covers `MOV r32, imm32`, and so on.

Output looks like:

```
        count       %  md opcode ext  m/r  mnemonic   operands               since  flags
     32165685  8.5819  32 85     -    r    TEST       r/m16/32, reg16/32     8086   oszapc
      5054907  1.3487  32 0F AD  -    r    SHRD       r/m16/32, reg16/32, CL 80386  oszapc
         1123  0.0005  16 0F 01  /3   m    LIDT       mem6/10                8086   -
            1  0.0000  32 0F 09  -    r    WBINVD                            80486  -
```

Note the last two rows: rarely executed but mandatory. The filter for the final
ISA set must be **"executed at least once"**, not "executed often".

## Result

A 10-minute cold boot of the demo image to the idle desktop:

```
8,849,650,841 instructions, 688 distinct encodings, 0 unresolved
50%: 12   90%: 48   99%: 185   99.9%: 343 encodings
```

~15 M emulated instructions/second with counting enabled. Full analysis in
[../instructions/README.md](../instructions/README.md) — the short version is
that a 80386 covers all but **seven** encodings, and the instructions that matter
most (`LTR`, `LLDT`, `MOV DRn`, `WBINVD`) each executed once or twice.

Trace files are large; keep `x86/win98/traces/` and `x86/win98/images/` out of git.
