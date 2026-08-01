# Instruction set comparison

| target | instructions executed | distinct encodings | mnemonics |
|---|---:|---:|---:|
| win98 | 8,944,845,475 | 868 | 148 |
| winnt | 1,004,351,858 | 690 | 135 |

union of all targets: **913** encodings
common to all targets: **645** encodings

## Only in win98 (223), not in winnt

| encoding | mnemonic | since | count | group |
|---|---|---|---:|---|
| `32b D0 3 [reg]` | RCR | 8086 | 69,330,529 | gen/shftrot |
| `32b D0 2 [reg]` | RCL | 8086 | 69,330,529 | gen/shftrot |
| `16b 9A [reg]` | CALLF | 8086 | 13,453,407 | gen/branch |
| `32b 87 [mem]` | XCHG | 8086 | 3,011,239 | gen/datamov |
| `32b 60 [reg]` | PUSHA | 80186 | 2,089,529 | gen/stack |
| `32b 61 [reg]` | POPA | 80186 | 2,089,385 | gen/stack |
| `16b 98 [reg]` | CBW | 8086 | 1,497,544 | gen/conver |
| `16b CA [reg]` | RETF | 8086 | 1,336,023 | gen/branch |
| `16b 7B [reg]` | JNP | 8086 | 777,253 | gen/branch/cond |
| `32b F9 [reg]` | STC | 8086 | 764,247 | gen/flgctrl |
| `16b 0F 8F [reg]` | JNLE | 80386 | 702,184 | gen/branch/cond |
| `16b 80 2 [reg]` | ADC | 8086 | 669,083 | gen/arith/binary |
| `16b FF 5 [mem]` | JMPF | 8086 | 597,521 | gen/branch |
| `32b F8 [reg]` | CLC | 8086 | 553,173 | gen/flgctrl |
| `32b 0F BA 6 [mem]` | BTR | 80286 | 443,584 | gen/bit |
| `32b AC [reg]` | LODS | 8086 | 425,886 | gen/datamov |
| `16b 34 [reg]` | XOR | 8086 | 407,357 | gen/logical |
| `32b D0 4 [reg]` | SHL | 8086 | 362,411 | gen/shftrot |
| `16b 33 [mem]` | XOR | 8086 | 342,895 | gen/logical |
| `16b 87 [mem]` | XCHG | 8086 | 318,552 | gen/datamov |
| `32b C1 1 [mem]` | ROR | 8086 | 314,453 | gen/shftrot |
| `16b FE 1 [mem]` | DEC | 8086 | 309,863 | gen/arith/binary |
| `16b 0F 8D [reg]` | JNL | 80386 | 257,521 | gen/branch/cond |
| `32b 8E [mem]` | MOV | 8086 | 237,679 | gen/datamov |
| `16b C1 1 [reg]` | ROR | 8086 | 216,839 | gen/shftrot |
| `16b AD [reg]` | LODS | 8086 | 216,606 | gen/datamov |
| `32b C1 1 [reg]` | ROR | 8086 | 212,759 | gen/shftrot |
| `16b 31 [mem]` | XOR | 8086 | 208,003 | gen/logical |
| `16b D0 2 [reg]` | RCL | 8086 | 159,773 | gen/shftrot |
| `32b E0 [reg]` | LOOPNZ | 8086 | 157,315 | gen/branch/cond |
| `16b 0F A9 [reg]` | POP | 80386 | 118,828 | gen/stack |
| `32b D1 1 [reg]` | ROR | 8086 | 114,241 | gen/shftrot |
| `32b 87 [reg]` | XCHG | 8086 | 100,717 | gen/datamov |
| `16b 63 [mem]` | ARPL | 80286 | 95,405 | system |
| `16b A7 [reg]` | CMPS | 8086 | 91,907 | gen/arith/binary |
| `32b 0F BA 6 [reg]` | BTR | 80286 | 90,593 | gen/bit |
| `32b D0 0 [reg]` | ROL | 8086 | 78,917 | gen/shftrot |
| `32b 0F B3 [mem]` | BTR | 80386 | 59,808 | gen/bit |
| `16b 80 6 [reg]` | XOR | 8086 | 56,091 | gen/logical |
| `16b 22 [reg]` | AND | 8086 | 53,932 | gen/logical |
| `32b D1 0 [reg]` | ROL | 8086 | 48,911 | gen/shftrot |
| `32b D0 1 [reg]` | ROR | 8086 | 45,672 | gen/shftrot |
| `16b D7 [reg]` | XLAT | 8086 | 43,868 | gen/datamov |
| `16b B6 [reg]` | MOV | 8086 | 34,344 | gen/datamov |
| `32b 0F 92 0 [mem]` | SETB | 80386 | 31,743 | gen/datamov |
| `32b 0F BA 4 [reg]` | BT | 80286 | 27,165 | gen/bit |
| `16b 30 [mem]` | XOR | 8086 | 26,970 | gen/logical |
| `16b 02 [reg]` | ADD | 8086 | 26,321 | gen/arith/binary |
| `16b 0F BF [mem]` | MOVSX | 80386 | 24,853 | gen/conver |
| `32b 91 [reg]` | XCHG | 8086 | 23,193 | gen/datamov |
| `32b 80 2 [mem]` | ADC | 8086 | 22,254 | gen/arith/binary |
| `16b 22 [mem]` | AND | 8086 | 20,311 | gen/logical |
| `32b 0F 02 [mem]` | LAR | 80286 | 19,226 | system |
| `16b D1 1 [reg]` | ROR | 8086 | 18,879 | gen/shftrot |
| `32b C8 [reg]` | ENTER | 80186 | 18,826 | gen/stack |
| `16b D1 0 [reg]` | ROL | 8086 | 18,615 | gen/shftrot |
| `16b 08 [mem]` | OR | 8086 | 18,326 | gen/logical |
| `16b D1 7 [reg]` | SAR | 8086 | 16,885 | gen/shftrot |
| `32b 0F BC [reg]` | BSF | 80386 | 16,575 | gen/bit |
| `16b D0 4 [reg]` | SHL | 8086 | 15,327 | gen/shftrot |

... and 163 more


## Only in winnt (45), not in win98

| encoding | mnemonic | since | count | group |
|---|---|---|---:|---|
| `32b 0F C7 1 [mem]` | CMPXCHG8B | P1 | 262,630 | gen/datamov/binary |
| `32b 0F B1 [mem]` | CMPXCHG | 80486 | 30,402 | gen/datamov/binary |
| `16b 0F 00 2 [reg]` | LLDT | 80286 | 26,017 | system |
| `16b 0F 01 1 [mem]` | SIDT | 80286 | 26,016 | system |
| `32b D2 4 [mem]` | SHL | 8086 | 12,583 | gen/shftrot |
| `32b 0F 01 7 [mem]` | INVLPG | 80486 | 4,488 | system |
| `32b D2 5 [reg]` | SHR | 8086 | 3,269 | gen/shftrot |
| `32b F7 3 [mem]` | NEG | 8086 | 1,696 | gen/arith/binary |
| `32b D9 0 [mem]` | FLD | 8086 | 1,287 | x87fpu/datamov |
| `32b D8 0 [mem]` | FADD | 8086 | 1,088 | x87fpu/arith |
| `32b D9 3 [mem]` | FSTP | 8086 | 879 | x87fpu/datamov |
| `32b 0F 80 [reg]` | JO | 80386 | 680 | gen/branch/cond |
| `32b D2 7 [reg]` | SAR | 8086 | 616 | gen/shftrot |
| `32b D8 1 [mem]` | FMUL | 8086 | 612 | x87fpu/arith |
| `32b DB 0 [mem]` | FILD | 8086 | 409 | x87fpu/datamov |
| `32b D8 6 [mem]` | FDIV | 8086 | 408 | x87fpu/arith |
| `32b DF 7 [mem]` | FISTP | 8086 | 340 | x87fpu/datamov |
| `32b D8 3 [mem]` | FCOMP | 8086 | 340 | x87fpu/compar |
| `32b 80 6 [mem]` | XOR | 8086 | 297 | gen/logical |
| `32b 0F 99 0 [reg]` | SETNS | 80386 | 191 | gen/datamov |
| `32b 70 [reg]` | JO | 8086 | 174 | gen/branch/cond |
| `32b DE 7 [reg]` | FIDIVR | 8086 | 136 | x87fpu/arith |
| `32b D9 2 [mem]` | FST | 8086 | 136 | x87fpu/datamov |
| `32b D8 7 [mem]` | FDIVR | 8086 | 136 | x87fpu/arith |
| `32b DC 0 [reg]` | FADD | 8086 | 131 | x87fpu/arith |
| `32b D2 5 [mem]` | SHR | 8086 | 110 | gen/shftrot |
| `16b 80 3 [reg]` | SBB | 8086 | 71 | gen/arith/binary |
| `32b D8 4 [mem]` | FSUB | 8086 | 68 | x87fpu/arith |
| `32b D9 0 [reg]` | FLD | 8086 | 68 | x87fpu/datamov |
| `32b DD 3 [reg]` | FSTP | 8086 | 68 | x87fpu/datamov |
| `32b D8 5 [mem]` | FSUBR | 8086 | 68 | x87fpu/arith |
| `32b D8 4 [reg]` | FSUB | 8086 | 68 | x87fpu/arith |
| `32b 0F 91 0 [reg]` | SETNO | 80386 | 42 | gen/datamov |
| `32b 0F A5 [reg]` | SHLD | 80386 | 27 | gen/shftrot |
| `32b DD 4 [mem]` | FRSTOR | 8086 | 11 | x87fpu/control |
| `32b 6E [reg]` | OUTS | 80186 | 8 | gen/inout |
| `32b 18 [mem]` | SBB | 8086 | 5 | gen/arith/binary |
| `32b 81 2 [mem]` | ADC | 8086 | 3 | gen/arith/binary |
| `32b 0F 01 2 [mem]` | LGDT | 80286 | 2 | system |
| `32b DD 7 [mem]` | FNSTSW | 8086 | 1 | x87fpu/control |
| `32b 0F 30 [reg]` | WRMSR | P1 | 1 | system |
| `16b 0F 00 3 [reg]` | LTR | 80286 | 1 | system |
| `32b DD 2 [mem]` | FST | 8086 | 1 | x87fpu/datamov |
| `32b 0F 32 [reg]` | RDMSR | P1 | 1 | system |
| `32b DC 7 [mem]` | FDIVR | 8086 | 1 | x87fpu/arith |

## Encodings by introducing CPU

| CPU | win98 | winnt |
|---|---:|---:|
| 80186 | 23 | 16 |
| 80286 | 36 | 17 |
| 80386 | 111 | 81 |
| 80486 | 4 | 5 |
| 8086 | 687 | 566 |
| ? | 3 | 0 |
| P1 | 2 | 5 |
| P2 | 2 | 0 |

## Post-80386 encodings

| encoding | mnemonic | since | win98 | winnt |
|---|---|---|---:|---:|
| `32b 0F BA 0 [mem]` | (#UD) | ? | 202 | - |
| `16b 0F FF [reg]` | (#UD) | ? | 1 | - |
| `16b 0F BA 0 [mem]` | (#UD) | ? | 1 | - |
| `32b 0F C8 [reg]` | BSWAP | 80486 | 1 | - |
| `32b 0F B1 [mem]` | CMPXCHG | 80486 | - | 30,402 |
| `32b 0F C7 1 [mem]` | CMPXCHG8B | P1 | - | 262,630 |
| `32b 0F A2 [reg]` | CPUID | 80486 | 12 | 15 |
| `32b 0F AE 1 [mem]` | FXRSTOR | P2 | 139 | - |
| `32b 0F AE 0 [mem]` | FXSAVE | P2 | 139 | - |
| `32b 0F 01 7 [mem]` | INVLPG | 80486 | - | 4,488 |
| `32b 0F 32 [reg]` | RDMSR | P1 | - | 1 |
| `32b 0F 31 [reg]` | RDTSC | P1 | 5,912,563 | 100 |
| `16b 0F 31 [reg]` | RDTSC | P1 | 3,279,765 | 4,855,176 |
| `32b 0F 09 [reg]` | WBINVD | 80486 | 1 | 1 |
| `32b 0F 30 [reg]` | WRMSR | P1 | - | 1 |
| `32b 0F C1 [mem]` | XADD | 80486 | 5,813 | 171,266 |
