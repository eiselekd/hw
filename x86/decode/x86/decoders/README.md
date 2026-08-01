# x86 decoder sources catalogue

Each decoder gets its own subdirectory here, either vendored (git submodule /
sparse checkout) or just a fetch script + converter.

| dir | project | URL | licence | data of interest |
|---|---|---|---|---|
| `xed/` | Intel XED | https://github.com/intelxed/xed | Apache-2.0 | `datafiles/**/-isa.txt`, `all-dec-instructions.txt` |
| `x86asm-net/` | x86asm.net reference | http://ref.x86asm.net/x86reference.xml | free | single XML with the whole opcode map |
| `nasm/` | NASM | https://github.com/netwide-assembler/nasm | BSD-2 | `x86/insns.dat` |
| `llvm/` | LLVM X86 backend | https://github.com/llvm/llvm-project | Apache-2.0 WLLVM | `llvm/lib/Target/X86/X86Instr*.td` |
| `capstone/` | Capstone | https://github.com/capstone-engine/capstone | BSD-3 | `arch/X86/X86*Tables.inc` (LLVM derived) |
| `zydis/` | Zydis | https://github.com/zyantific/zydis | MIT | `Generated/*.inc`, `Data/instructions.json` |
| `v86/` | copy/v86 (JS/WASM PC emulator, boots Win98 in browser) | https://github.com/copy/v86 | BSD-2 | `gen/x86_table.js`, `src/rust/cpu/`, `src/rust/opstats.rs` |
| `v86-patch/` | our `win98stats` instrumentation for the above | — | — | tracked; reapply with `git apply` |
| `pcjs/` | PCjs | https://github.com/jeffpar/pcjs | MIT | `machines/pcx86/modules/v2/x86op*.js` |
| `udis86/` | udis86 | https://github.com/vmt/udis86 | BSD-2 | `docs/x86/optable.xml` (very clean XML) |
| `fake86/` | fake86 / 8086tiny | — | GPL/MIT | 16-bit only, sanity check |
| `sdm/` | Intel SDM Vol.2 App. A | intel.com | — | authoritative fallback, PDF |

## Recommended "read the source and emit a text layout list" candidates

1. **udis86 `optable.xml`** — smallest, already XML, one entry per encoding.
2. **x86asm.net `x86reference.xml`** — most complete single file, has opcode
   extensions, prefixes, flags effects, and CPU-level (`8086`,`80386`,`P5`...).
3. **v86 `gen/x86_table.js`** — a JavaScript project; the table is a plain JS
   array of `{opcode, os, e (has modrm), mask, custom, block_boundary, ...}`
   and is used to *generate* the decoder — ideal for the JS route.
4. **Zydis `instructions.json`** — decoder-centric, already JSON.

## Fetch

Run `x86/decoders/fetch.sh <name>...` (shallow clones / curl into this dir).
Nothing here is committed except converters and notes.
