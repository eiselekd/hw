# Win98 boot instruction census — results

Produced by Phase 1 of [../../plan.md](../../plan.md) using the instrumented
v86 build described in [../tools/README.md](../tools/README.md).

**Workload:** the exact disk image the hosted demo at copy.sh/v86 uses
(`i.copy.sh/windows98/`, 300 MB FAT16, 128 MB RAM, SeaBIOS), booted from power-on
to the Windows 98 GUI, then left idle. Reproduce with:

```sh
cd ../tools
./fetch_image.sh windows98
./census_node.mjs --profile windows98-boot --seconds 600 --phase-every 120 \
    --screen --out ../traces/win98.boot.tsv
./aggregate.py ../traces/win98.boot.tsv -o win98.hist.tsv \
    --coverage win98.coverage.md --opcodes win98.opcodes.txt
./annotate.py win98.hist.tsv -o win98.isa.txt --json win98.isa.json
```

The GUI comes up at ~55 s of wall clock (`[screen] 640x480 4bpp graphical`).

## Files

| file | meaning |
|---|---|
| `win98.hist.tsv` | `count · mode · opcode · /ext · mnemonic`, sorted by count |
| `win98.coverage.md` | how many encodings are needed for N % of execution |
| `win98.opcodes.txt` | de-duplicated encoding list |
| `win98.isa.txt` | the above joined with mnemonics + operand layouts |
| `win98.isa.json` | same, machine readable, for Phase 2/3 |

## Headline numbers

```
8,849,650,841 instructions executed
          688 distinct encodings   (opcode + /ext + mem/reg + code-size)
          147 distinct mnemonics
            0 unresolved against the reference
```

| coverage | encodings needed |
|---|---|
| 50 % | 12 |
| 90 % | 48 |
| 99 % | 185 |
| 99.9 % | 343 |
| 100 % | 688 |

Half of all execution is twelve encodings:

```
  9.86%  74       JZ    rel8sx
  8.78%  8B       MOV   reg16/32, r/m16/32
  5.24%  75       JNZ   rel8sx
  4.91%  85       TEST  r/m16/32, reg16/32
  3.80%  F6 /0    TEST  r/m8, imm8
  3.70%  33       XOR   reg16/32, r/m16/32
  3.00%  C3       RETN
  2.79%  81 /7    CMP   r/m16/32, imm16/32sx
  2.78%  80 /7    CMP   r/m8, imm8
  2.62%  83 /7    CMP   r/m16/32, imm8sx
  2.49%  8A       MOV   reg8, r/m8
  2.05%  0F 84    JZ    rel16/32sx
```

## What CPU do you actually need?

By the reference's `proc_start` field:

| introduced with | encodings |
|---|---|
| 8086 | 560 |
| 80186 | 19 |
| 80286 | 6 |
| 80386 | 93 |
| 80486 | 3 |
| Pentium | 2 |
| Pentium II | 2 |
| (invalid, see below) | 3 |

So a **80386 covers all but seven encodings**. The complete post-386 set is:

```
   3,279,857  P1     0F 31       RDTSC
       5,813  80486  0F C1       XADD
         139  P2     0F AE /0    FXSAVE
         139  P2     0F AE /1    FXRSTOR
          12  80486  0F A2       CPUID
           1  80486  0F 09       WBINVD
```

Notably absent from this boot: **no MMX, no SSE, no CMPXCHG8B**. By instruction
class the split is 631 general, 30 system, 22 x87 FPU.

## The long tail is the interesting part

Frequency is a terrible filter for "do I need to implement this". These all ran
**exactly once or twice** and are still mandatory:

```
   1  0F 00 /3   LTR      r/m16                  load task register
   1  0F 00 /1   STR      mem16
   1  0F 09      WBINVD
   1  0F 21      MOV      r32, DRn                debug register read
   2  0F 01 /1   SIDT     mem6/10
   4  0F 00 /2   LLDT     r/m16
   6  0F 23      MOV      DRn, r32
```

Plus the protected-mode bring-up itself — `LGDT` 118×, `LIDT` 238×,
`MOV CR0` 239× in 16-bit mode, `CLTS` 492×, `ARPL` 121,324×, `HLT` 100,077×.

**The filter for the final ISA set must be "executed at least once", not
"executed often".** This is exactly why the census counts the interpreter path
and not just JIT-compiled blocks — none of the above is ever hot enough to be
compiled.

## Invalid encodings

Three encodings are genuine `#UD` traps, not gaps in the reference:

```
 202  32b 0F BA /0   reserved slot in opcode group  (BT group defines only /4../7)
   1  16b 0F BA /0   same
   1  16b 0F FF      undocumented opcode (UD0)
```

`annotate.py` classifies these by reason so a real bug in the joiner is never
silently reported as "invalid".

## Caveats

- One boot on one image; drivers for other hardware will pull in more.
- Idle-at-desktop only. Running applications (the demo ships FreeCell, Hearts,
  IE 5) would extend the x87 and string-instruction tails.
- Win98 *setup* is not covered and requires more than a 386.
- `--phase-every` snapshots are in `../traces/`; per-phase histograms let the
  BIOS / real-mode DOS / protected-mode switch / VMM32 / GUI stages be separated.
