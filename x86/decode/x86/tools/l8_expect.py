#!/usr/bin/env python3
"""Expected-results table for `decode_x86_withdecode_extended_operands.l8`.

Reads the decoded database (`winnt.decoded.jsonl`, itself cross-checked against
iced-x86) and, for every instruction Windows NT executed, states what that l8
file *should* produce:

  * which leaf of the `bitslice x86` opcode tree (§2) is reached  -> `variant`
  * which `decode(d) { ... }` arm fires (§3)                      -> `arm`
  * the values the arm's argument list binds                      -> `args`
  * the arm's `end` expression and its value in bits              -> `end`

So each row is `instruction bytes in -> arm + bound arguments + length out`,
which is the whole contract of §3.  Feed the `bytes` column to the l8 decoder
and compare the rest.

WHY THIS IS A TEST AND NOT A RESTATEMENT
----------------------------------------
The arm table below is transcribed from the l8 file, so on its own it would
only prove the transcription.  What makes it a test is `end`: the arm's length
expression is evaluated here (`@modrm8` from the real modrm extent, `p.osz`
from the real prefixes) and compared against the instruction length that
iced-x86 independently determined.  The `end_ok` column is therefore a genuine
verdict on §3's `end` column, available *before* the l8 decoder runs at all —
and §4.4 of the l8 file argues exactly this: that `end` is where an arm's
binding list can be checked against something outside itself.

Rows where the tree reaches no arm are kept with `arm = _` (the trap_undefined
catch-all).  That is the other useful output: the list of encodings NT actually
executes that this deliberately-partial decoder does not yet cover.

    ../.venv/bin/python l8_expect.py
"""

import argparse
import csv
import json
import os
import sys

# ---------------------------------------------------------------- cc_t (§1)

CC = ["o", "no", "b", "nb", "z", "nz", "be", "nbe",
      "s", "ns", "p", "np", "l", "nl", "le", "nle"]

ALU_MR = ["add_mr", "or_mr", "adc_mr", "sbb_mr", "and_mr", "sub_mr", "xor_mr", "cmp_mr"]
ALU_RM = [n.replace("_mr", "_rm") for n in ALU_MR]
ALU_AI = [n.replace("_mr", "_ai") for n in ALU_MR]
ALU_MI8 = [n.replace("_mr", "_mi8") for n in ALU_MR]
ALU_MIZ = [n.replace("_mr", "_miz") for n in ALU_MR]
ALU_MIS = [n.replace("_mr", "_mis") for n in ALU_MR]
SHIFT = ["rol", "ror", "rcl", "rcr", "shl", "shr", None, "sar"]


# ---------------------------------------------------------------- §2 the tree

def variant(rec):
    """Walk `bitslice x86`'s `op: 0..7 ==` table.  Returns (name, fields).

    `fields` are the values the tree binds along the way (`opreg`, `w`,
    `aluop`, `cc`, ...), which §3's arms then name in their argument lists.
    Arm order below follows the file, because the file's order is load-bearing:
    §2.1 must come first, since seg_stack's mask in §2.3 covers 0x0F.
    """
    op = int(rec["op"][-2:], 16)
    is0f = rec["is0f"]
    m = rec["modrm"]
    reg = m["reg"] if m else None
    f = {"opreg": op & 7, "w": op & 1, "d": (op >> 1) & 1}

    if is0f:                                                    # § 2.1
        f["op2"] = op
        if op == 0x00:
            return {0: "sldt", 1: "str", 2: "lldt", 3: "ltr", 5: "verw"}.get(reg), f
        if op == 0x01:
            return {0: "sgdt", 1: "sidt", 2: "lgdt", 3: "lidt",
                    4: "smsw", 7: "invlpg"}.get(reg), f
        simple = {0x02: "lar", 0x03: "lsl", 0x06: "clts", 0x30: "wrmsr",
                  0x32: "rdmsr", 0x09: "wbinvd", 0x31: "rdtsc", 0xA2: "cpuid",
                  0x20: "mov_from_cr", 0x22: "mov_to_cr",
                  0x21: "mov_from_dr", 0x23: "mov_to_dr",
                  0xA0: "push_fs", 0xA8: "push_gs", 0xA1: "pop_fs",
                  0xA9: "pop_gs", 0xA3: "bt_mr", 0xB3: "btr_mr",
                  0xAB: "bts_mr", 0xBB: "btc_mr", 0xA4: "shld_i",
                  0xAC: "shrd_i", 0xA5: "shld_cl", 0xAD: "shrd_cl",
                  0xBC: "bsf", 0xBD: "bsr", 0xB2: "lss", 0xB4: "lfs",
                  0xB5: "lgs", 0xB1: "cmpxchg", 0xC1: "xadd", 0xAF: "imul_rm",
                  0xB6: "movzx_b", 0xBE: "movsx_b",
                  0xB7: "movzx_w", 0xBF: "movsx_w"}
        if op in simple:
            return simple[op], f
        if 0x80 <= op <= 0x8F:
            f["cc"] = op & 0xF
            return "jnear", f
        if 0x90 <= op <= 0x9F:
            f["cc"] = op & 0xF
            return "setcc", f
        if op == 0xBA:
            return {4: "bt_mi", 5: "bts_mi", 6: "btr_mi", 7: "btc_mi"}.get(reg), f
        if op == 0xC7:
            return ("cmpxchg8b" if reg == 1 else None), f
        if op == 0xAE:
            return {0: "fxsave", 1: "fxrstor"}.get(reg), f
        if 0xC8 <= op <= 0xCF:
            f["opreg2"] = op & 7
            return "bswap", f
        return None, f

    op7 = op & 7
    if (op >> 6) == 0 and op7 <= 5:                             # § 2.2  ALU
        f["aluop"] = (op >> 3) & 7
        tbl = ALU_MR if op7 < 2 else (ALU_RM if op7 < 4 else ALU_AI)
        return tbl[f["aluop"]], f
    if (op >> 5) == 0 and op7 in (6, 7):                        # § 2.3  seg
        f["sreg"] = (op >> 3) & 3
        f["pop"] = op & 1
        return {0x06: "push_es", 0x16: "push_ss", 0x1E: "push_ds",
                0x07: "pop_es", 0x17: "pop_ss", 0x1F: "pop_ds",
                0x0E: "push_cs"}.get(op), f
    if 0x40 <= op <= 0x5F or 0x90 <= op <= 0x97 or 0xB0 <= op <= 0xBF:
        top = op >> 3                                           # § 2.4  reg-in-op
        return {0x08: "inc_r", 0x09: "dec_r", 0x0A: "push_r", 0x0B: "pop_r",
                0x12: "xchg_ax", 0x16: "mov_ri8", 0x17: "mov_riv"}[top], f
    if op in (0x60, 0x61, 0x63, 0x68, 0x6A, 0x69, 0x6B):        # § 2.5
        return {0x60: "pusha", 0x61: "popa", 0x63: "arpl", 0x68: "push_iz",
                0x6A: "push_ib", 0x69: "imul_rmi", 0x6B: "imul_rmib"}[op], f
    if 0x6C <= op <= 0x6D:
        return "ins", f
    if 0x6E <= op <= 0x6F:
        return "outs", f
    if 0x70 <= op <= 0x7F:                                      # § 2.6  Jcc
        f["cc"] = op & 0xF
        return "jshort", f
    if 0x80 <= op <= 0x83:                                      # § 2.7  group 1
        tbl = ALU_MI8 if op in (0x80, 0x82) else (ALU_MIZ if op == 0x81 else ALU_MIS)
        return tbl[reg], f
    if 0x84 <= op <= 0x8F:                                      # § 2.8
        if op in (0x84, 0x85): return "test_mr", f
        if op in (0x86, 0x87): return "xchg_mr", f
        if op in (0x88, 0x89): return "mov_mr", f
        if op in (0x8A, 0x8B): return "mov_rm", f
        if op == 0x8C: return "mov_msreg", f
        if op == 0x8D: return "lea", f
        if op == 0x8E: return "mov_sregm", f
        return ("pop_m" if reg == 0 else None), f
    if 0xA0 <= op <= 0xAF:                                      # § 2.9  accum
        return {0xA0: "mov_a_moffs", 0xA1: "mov_a_moffs",
                0xA2: "mov_moffs_a", 0xA3: "mov_moffs_a",
                0xA4: "movs", 0xA5: "movs", 0xA6: "cmps", 0xA7: "cmps",
                0xA8: "test_ai", 0xA9: "test_ai", 0xAA: "stos", 0xAB: "stos",
                0xAC: "lods", 0xAD: "lods", 0xAE: "scas", 0xAF: "scas"}[op], f
    if op in (0xC0, 0xC1, 0xD0, 0xD1, 0xD2, 0xD3):              # § 2.10 shifts
        base = SHIFT[reg]
        if base is None:
            return None, f
        sfx = "_mi" if op in (0xC0, 0xC1) else ("_m1" if op in (0xD0, 0xD1) else "_mcl")
        return base + sfx, f
    if op in (0x9A, 0xC2, 0xCA, 0xCD, 0xC3, 0xCB):              # § 2.11
        return {0x9A: "callf_ptr", 0xC2: "retn_i", 0xCA: "retf_i",
                0xCD: "int_i", 0xC3: "retn", 0xCB: "retf"}[op], f
    if 0xE0 <= op <= 0xE3:
        return {0xE0: "loopnz", 0xE1: "loopz", 0xE2: "loop", 0xE3: "jcxz"}[op], f
    if 0xE8 <= op <= 0xEB:
        return {0xE8: "call_rel", 0xE9: "jmp_rel",
                0xEA: "jmpf_ptr", 0xEB: "jmp_rel8"}[op], f
    if op in (0xC4, 0xC5, 0xC8):
        return {0xC4: "les", 0xC5: "lds", 0xC8: "enter"}[op], f
    if op in (0xC6, 0xC7):                                      # § 2.12 group 11
        if reg != 0:
            return None, f
        return ("mov_mi8" if op == 0xC6 else "mov_miz"), f
    if 0xD8 <= op <= 0xDF:                                      # § 2.13 x87
        f["op7"] = op7
        x87 = {
            0: {0: "fadd_32", 1: "fmul_32", 3: "fcomp_32", 4: "fsub_32",
                5: "fsubr_32", 6: "fdiv_32", 7: "fdivr_32"},
            1: {0: "fld_32", 2: "fst_32", 3: "fstp_32", 5: "fldcw", 7: "fnstcw"},
            3: {0: "fild_32", 4: "fneni"},
            4: {0: "fadd_64", 1: "fmul_64", 3: "fcomp_64", 5: "fsubr_64",
                6: "fdiv_64", 7: "fdivr_64"},
            5: {0: "fld_64", 2: "fst_64", 3: "fstp_64", 4: "frstor",
                6: "fnsave", 7: "fnstsw"},
            6: {3: "ficomp_16", 7: "fidivr_16"},
            7: {4: "fbld", 7: "fistp_64"},
        }.get(op7, {})
        return x87.get(reg), f
    if (op & 0xF4) == 0xE4:                                     # § 2.14 port IO
        f["dx"] = (op >> 3) & 1
        f["out"] = (op >> 1) & 1
        return {0xE4: "in_i", 0xE5: "in_i", 0xE6: "out_i", 0xE7: "out_i",
                0xEC: "in_dx", 0xED: "in_dx", 0xEE: "out_dx", 0xEF: "out_dx"}[op], f
    if op in (0xF6, 0xF7):                                      # § 2.15 group 3
        return {0: "test_mi", 2: "not_m", 3: "neg_m", 4: "mul_m",
                5: "imul_m", 6: "div_m", 7: "idiv_m"}.get(reg), f
    if 0xF8 <= op <= 0xFD:                                      # § 2.16 flags
        f["which"] = (op >> 1) & 1
        f["set"] = op & 1
        return {0xF8: "clc", 0xF9: "stc", 0xFA: "cli", 0xFB: "sti",
                0xFC: "cld", 0xFD: "std"}[op], f
    if op in (0xFE, 0xFF):                                      # § 2.17 groups 4/5
        if op == 0xFE:
            return {0: "inc_m8", 1: "dec_m8"}.get(reg), f
        return {0: "inc_m", 1: "dec_m", 2: "call_m", 3: "callf_m",
                4: "jmp_m", 5: "jmpf_m", 6: "push_m"}.get(reg), f
    strays = {0x98: "cbw", 0x99: "cwd", 0x9B: "fwait", 0x9C: "pushf",
              0x9D: "popf", 0x9E: "sahf", 0x9F: "lahf", 0xC9: "leave",
              0xCF: "iret", 0xD4: "aam", 0xD5: "aad", 0xD7: "xlat",
              0xF4: "hlt", 0xF5: "cmc"}                         # § 2.18
    return strays.get(op), f


# ---------------------------------------------------------------- §3 the arms
#
# (variant, modrm-kind guard or None, argument names, `end` as written).
# Transcribed from `decode(d) { ... }`, in file order.  `end` is a string so
# the table stays readable next to the l8 file; it is evaluated by `end_of()`.

ARMS = [
    ("xchg_ax", "opreg==0", ["opreg"], "8", "is_nop=1"),
    ("xchg_ax", None, ["opreg"], "8", "swap=1"),
    ("inc_r", None, ["opreg"], "8", "alu=1"),
    ("dec_r", None, ["opreg"], "8", "alu=2"),
    ("push_r", None, ["opreg"], "8", "stack=1"),
    ("pop_r", None, ["opreg"], "8", "stack=2"),
    ("mov_ri8", None, ["opreg", "imm8"], "8 + 8", "load_imm=1"),
    ("mov_riv", None, ["opreg", "immz"], "8 + p.osz*8", "load_imm=2"),

    ("add_mr", None, ["modrm8", "w"], "@modrm8", "alu=3"),
    ("add_rm", None, ["modrm8", "w"], "@modrm8", "alu=3"),
    ("add_ai", None, ["imm", "w"], "8 + sz*8", "alu=3"),
    ("add_mi8", None, ["modrm8", "imm8"], "@modrm8 + 8", "alu=3"),
    ("add_miz", None, ["modrm8", "immz"], "@modrm8 + p.osz*8", "alu=3"),
    ("add_mis", None, ["modrm8", "imm8"], "@modrm8 + 8", "alu=3"),
    ("cmp_mr", None, ["modrm8", "w"], "@modrm8", "alu=4"),
    ("cmp_rm", None, ["modrm8", "w"], "@modrm8", "alu=4"),
    ("cmp_mi8", None, ["modrm8", "imm8"], "@modrm8 + 8", "alu=4"),
    ("cmp_mis", None, ["modrm8", "imm8"], "@modrm8 + 8", "alu=4"),
    ("xor_rm", None, ["modrm8", "w"], "@modrm8", "alu=5"),
    ("and_mi8", None, ["modrm8", "imm8"], "@modrm8 + 8", "alu=6"),
    ("test_mi", None, ["modrm8", "imm", "w"], "@modrm8 + sz*8", "alu=7"),
    ("test_mr", None, ["modrm8", "w"], "@modrm8", "alu=7"),

    ("mov_rm", "reg_direct", ["modrm8"], "@modrm8", "move=1"),
    ("mov_rm", None, ["modrm8", "w"], "@modrm8", "move=2"),
    ("mov_mr", None, ["modrm8", "w"], "@modrm8", "move=3"),
    ("mov_mi8", None, ["modrm8", "imm8"], "@modrm8 + 8", "move=4"),
    ("mov_miz", None, ["modrm8", "immz"], "@modrm8 + p.osz*8", "move=4"),
    ("lea", "base_d8", ["modrm8"], "@modrm8", "move=5"),
    ("lea", "base_d32", ["modrm8"], "@modrm8", "move=5"),
    ("lea", "sib_d32", ["modrm8"], "@modrm8", "move=5"),
    ("lea", "abs32", ["modrm8"], "@modrm8", "move=5"),
    ("lea", "reg_direct", ["modrm8"], "@modrm8", "trap_undefined=1"),
    ("mov_a_moffs", None, ["moffs", "w"], "8 + p.asz*8", "move=6"),
    ("mov_moffs_a", None, ["moffs", "w"], "8 + p.asz*8", "move=7"),
    ("movzx_b", None, ["modrm16"], "@modrm16", "move=8"),
    ("movzx_w", None, ["modrm16"], "@modrm16", "move=8"),
    ("movsx_b", None, ["modrm16"], "@modrm16", "move=9"),

    ("jshort.z", None, ["rel8"], "8 + 8", "branch=1"),
    ("jnear.z", None, ["rel"], "16 + p.osz*8", "branch=1"),
    ("jshort.nz", None, ["rel8"], "8 + 8", "branch=2"),
    ("jnear.nz", None, ["rel"], "16 + p.osz*8", "branch=2"),
    ("jshort.b", None, ["rel8"], "8 + 8", "branch=7"),
    ("jshort.nbe", None, ["rel8"], "8 + 8", "branch=8"),
    ("jmp_rel8", None, ["rel8"], "8 + 8", "branch=3"),
    ("jmp_rel", None, ["rel"], "8 + p.osz*8", "branch=3"),
    ("jmp_m", None, ["modrm8"], "@modrm8", "branch=4"),
    ("loop", None, ["rel8"], "8 + 8", "branch=5"),
    ("jcxz", None, ["rel8"], "8 + 8", "branch=6"),

    ("call_rel", None, ["rel"], "8 + p.osz*8", "call=1"),
    ("call_m", None, ["modrm8"], "@modrm8", "call=2"),
    ("callf_ptr", None, ["ptr"], "8 + p.osz*8 + 16", "call=3"),
    ("retn", None, [], "8", "ret=1"),
    ("retn_i", None, ["imm16"], "8 + 16", "ret=2"),
    ("retf", None, [], "8", "ret=3"),
    ("iret", None, [], "8", "ret=4"),

    ("setcc.z", None, ["modrm16"], "@modrm16", "setcc=1"),
    ("setcc.nz", None, ["modrm16"], "@modrm16", "setcc=2"),
    ("setcc.nbe", None, ["modrm16"], "@modrm16", "setcc=3"),

    ("shl_mi", None, ["modrm8", "w", "imm8"], "@modrm8 + 8", "shift=1"),
    ("shl_m1", None, ["modrm8", "w"], "@modrm8", "shift=2"),
    ("shl_mcl", None, ["modrm8", "w"], "@modrm8", "shift=3"),
    ("sar_mi", None, ["modrm8", "w", "imm8"], "@modrm8 + 8", "shift=4"),
    ("shld_i", None, ["modrm16", "imm8"], "@modrm16 + 8", "shift=5"),
    ("shrd_cl", None, ["modrm16"], "@modrm16", "shift=6"),

    ("push_m", None, ["modrm8"], "@modrm8", "stack=3"),
    ("push_iz", None, ["immz"], "8 + p.osz*8", "stack=4"),
    ("push_ib", None, ["imm8"], "8 + 8", "stack=5"),
    ("pop_m", None, ["modrm8"], "@modrm8", "stack=6"),
    ("push_es", None, [], "8", "stack=7"),
    ("push_fs", None, [], "16", "stack=7"),
    ("enter", None, ["imm16", "imm8"], "8 + 16 + 8", "frame=1"),
    ("leave", None, [], "8", "frame=2"),

    ("cli", None, [], "8", "priv=1"),
    ("sti", None, [], "8", "priv=2"),
    ("hlt", None, [], "8", "priv=3"),
    ("clts", None, [], "16", "priv=4"),
    ("lgdt", None, ["modrm16"], "@modrm16", "priv=5"),
    ("lidt", None, ["modrm16"], "@modrm16", "priv=6"),
    ("invlpg", None, ["modrm16"], "@modrm16", "priv=7"),
    ("mov_to_cr", "reg_direct", ["modrm16"], "@modrm16", "priv=8"),
    ("mov_from_cr", "reg_direct", ["modrm16"], "@modrm16", "priv=9"),
    ("rdtsc", None, [], "16", "priv=10"),
    ("cpuid", None, [], "16", "priv=11"),

    ("in_i", None, ["imm8", "w"], "8 + 8", "io=1"),
    ("out_i", None, ["imm8", "w"], "8 + 8", "io=2"),
    ("in_dx", None, ["w"], "8", "io=3"),
    ("out_dx", None, ["w"], "8", "io=4"),

    ("movs", None, ["w"], "8", "string=1"),
    ("stos", None, ["w"], "8", "string=2"),
    ("lods", None, ["w"], "8", "string=3"),
    ("scas", None, ["w"], "8", "string=4"),
    ("cmps", None, ["w"], "8", "string=5"),

    ("fld_32", None, ["modrm8"], "@modrm8", "fpu=1"),
    ("fld_64", None, ["modrm8"], "@modrm8", "fpu=1"),
    ("fstp_32", None, ["modrm8"], "@modrm8", "fpu=2"),
    ("fnstcw", None, ["modrm8"], "@modrm8", "fpu=3"),
    ("fldcw", None, ["modrm8"], "@modrm8", "fpu=4"),
]


def select_arm(name, f, rec):
    """First matching arm wins, as in the l8 file.  `jshort`/`jnear`/`setcc`
    are matched on the cc payload, which is how §3 spells them
    (`jshort.z.(rel8)`), so a cc the file does not list falls through to `_`."""
    if name is None:
        return None
    key = name
    if name in ("jshort", "jnear", "setcc"):
        key = "%s.%s" % (name, CC[f["cc"]])
    kind = rec["modrm"]["kind"] if rec["modrm"] else None
    for vname, guard, args, end, res in ARMS:
        if vname != key:
            continue
        if guard is None:
            return (key, None, args, end, res)
        if guard == "opreg==0":
            if f["opreg"] == 0:
                return (key, guard, args, end, res)
        elif guard == kind:
            return (key, guard, args, end, res)
    return None


def end_of(expr, rec, f):
    """Evaluate an arm's `end`, in bits from the opcode byte (i.e. from `@pfx`).

    `@modrm8` / `@modrm16` are the §1 five-way extent mux: the opcode's own
    width plus the modrm+sib+disp extent.  `sz` is the arm-local `w ? p.osz : 1`.
    """
    m = rec["modrm"]
    ext = m["extent"] * 8 if m else 0
    env = {
        "@modrm8": 8 + ext,
        "@modrm16": 16 + ext,
        "p.osz": rec["pfx"]["osz"],
        "p.asz": rec["pfx"]["asz"],
        "sz": rec["pfx"]["osz"] if f.get("w") else 1,
    }
    e = expr
    for k, v in env.items():
        e = e.replace(k, str(v))
    return eval(e, {"__builtins__": {}})


def arg_values(args, rec, f):
    """Bind the arm's argument list to concrete values."""
    m = rec["modrm"]
    out = []
    for a in args:
        if a in ("modrm8", "modrm16"):
            if not m:
                out.append("%s=?" % a)
                continue
            parts = ["kind=%s" % m["kind"], "mod=%d" % m["mod"],
                     "reg=%d" % m["reg"], "rm=%d" % m["rm"]]
            if m["b"] is not None: parts.append("b=%d" % m["b"])
            if m["x"] is not None: parts.append("x=%d" % m["x"])
            if m["s"] is not None: parts.append("s=%d" % m["s"])
            if m["disp_bits"]:
                parts.append("disp=%d@%d:%d"
                             % (m["disp"], m["disp_at"] * 8, m["disp_bits"]))
            out.append("%s{%s}" % (a, ",".join(parts)))
        elif a in ("imm8", "imm16", "immz", "imm", "rel", "rel8", "moffs", "ptr"):
            if rec["imm_bits"]:
                out.append("%s=0x%x@%d:%d"
                           % (a, rec["imm"], rec["imm_at"] * 8, rec["imm_bits"]))
            else:
                out.append("%s=?" % a)
        else:
            out.append("%s=%s" % (a, f.get(a, "?")))
    return ";".join(out)


# `arm` is the arm as it is written in the file, guard included
# (`lea.(modrm8: base_d8)` -> `lea:base_d8`), because several variants have
# more than one arm and only the guard tells them apart.  `res` is the arm's
# result assignment, which is the other half of what it produces.
COLUMNS = ["bytes", "mode", "len", "count", "at", "pfx", "osz", "asz", "seg",
           "rep", "variant", "arm", "args", "res", "end_expr", "end",
           "end_ok", "text"]

# Right-align the numeric columns, left-align the rest: a column of counts is
# only comparable by eye when the digits line up.
RIGHT = {"mode", "len", "count", "at", "pfx", "osz", "asz", "end", "end_ok"}


def write_aligned(path, rows):
    """Write a comma-separated table whose columns line up.

    Padding goes INSIDE the quotes for fields that need quoting, and before the
    separator otherwise, so the result is still valid CSV: `csv.reader` parses
    it unchanged and every value simply needs `.strip()`.  Spaces only, never
    tabs — a tab's width is a property of the viewer, which is exactly what
    alignment must not depend on.
    """
    cells = [[("" if c is None else str(c)) for c in r] for r in rows]
    width = [max(len(r[i]) for r in cells) for i in range(len(COLUMNS))]

    def render(v, w, col):
        pad = v.rjust(w) if col in RIGHT else v.ljust(w)
        if '"' in v or "," in v:
            return '"' + pad.replace('"', '""') + '"'
        return pad

    with open(path, "w") as f:
        for r in cells:
            f.write(", ".join(render(v, width[i], COLUMNS[i])
                              for i, v in enumerate(r)).rstrip() + "\n")


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    dbdir = os.path.join(here, "..", "winnt", "instructions", "decoded_database")
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--db", default=os.path.join(dbdir, "winnt.decoded.jsonl"))
    ap.add_argument("--out", default=os.path.join(dbdir, "winnt.l8_expect.csv"))
    a = ap.parse_args()

    n = covered = end_bad = 0
    uncovered = {}
    bad_examples = []
    dyn_cov = dyn_unc = 0
    rows = [COLUMNS]

    with open(a.db) as fin:
        for line in fin:
            rec = json.loads(line)
            n += 1
            name, f = variant(rec)
            arm = select_arm(name, f, rec)
            p = rec["pfx"]
            kind = rec["modrm"]["kind"] if rec["modrm"] else "-"

            if arm is None:
                # Record the addressing mode too: `lea` has arms for four modrm
                # kinds and NT uses seven, so "which variant" is not enough to
                # say what is missing.
                k = (name or ("op " + rec["op"]), kind)
                uncovered[k] = uncovered.get(k, 0) + 1
                dyn_unc += rec["count"]
                rows.append([rec["bytes"], rec["mode"], rec["len"], rec["count"],
                             rec["at"] * 8, p["n"], p["osz"], p["asz"],
                             p["seg"] or "", p["rep"] or "",
                             name or "?", "_", "", "trap_undefined=1",
                             "", "", "", rec["text"]])
                continue

            covered += 1
            dyn_cov += rec["count"]
            key, guard, args, expr, res = arm
            armname = key + (":" + guard if guard else "")
            end = end_of(expr, rec, f)
            # The verdict: the arm's own length expression against the length a
            # reference decoder derived from the same bytes.
            ok = (end + p["n"] * 8) == rec["len"] * 8
            if not ok:
                end_bad += 1
                if len(bad_examples) < 25:
                    bad_examples.append((rec["bytes"], rec["mode"], armname, expr,
                                         end, rec["len"] * 8 - p["n"] * 8,
                                         rec["text"]))
            rows.append([rec["bytes"], rec["mode"], rec["len"], rec["count"],
                         rec["at"] * 8, p["n"], p["osz"], p["asz"],
                         p["seg"] or "", p["rep"] or "",
                         name, armname, arg_values(args, rec, f), res, expr,
                         end, 1 if ok else 0, rec["text"]])

    write_aligned(a.out, rows)

    print("%d encodings: %d reach an arm, %d fall through to `_`"
          % (n, covered, n - covered))
    print("end: %d correct, %d WRONG" % (covered - end_bad, end_bad))
    if bad_examples:
        print("\nmismatched `end` (arm says / bytes say):")
        for b, mo, k, e, got, want, t in bad_examples:
            print("  %-18s %db %-14s end = %-20s -> %3d  want %3d   %s"
                  % (b, mo, k, e, got, want, t))

    rep = os.path.join(os.path.dirname(a.out), "winnt.l8_gaps.md")
    write_gaps(rep, n, covered, end_bad, bad_examples, uncovered,
               dyn_cov, dyn_unc)
    print("\nwrote " + a.out)
    print("wrote " + rep)


def write_gaps(path, n, covered, end_bad, bad, uncovered, dyn_cov, dyn_unc):
    with open(path, "w") as f:
        w = f.write
        w("# `decode_x86_withdecode_extended_operands.l8` vs. a Windows NT boot\n\n")
        w("Generated by `x86/tools/l8_expect.py` from the decoded database.\n"
          "It walks the l8 file's §2 opcode tree and §3 arm list for every\n"
          "encoding NT executed, and reports two things: whether an arm exists,\n"
          "and whether that arm's `end` is right.\n\n")
        w("## `end` — the one claim checkable without running the decoder\n\n")
        w("Each arm's `end` expression is evaluated with `@modrm8` taken from\n"
          "the real modrm extent and `p.osz`/`p.asz` from the real prefixes,\n"
          "then compared against the instruction length iced-x86 derived\n"
          "independently from the same bytes.\n\n")
        w("| arms exercised | `end` correct | `end` wrong |\n|---:|---:|---:|\n")
        w("| %d | %d | %d |\n\n" % (covered, covered - end_bad, end_bad))
        if bad:
            w("| bytes | arm | `end` | value | actual |\n|---|---|---|---:|---:|\n")
            for b, mo, k, e, got, want, t in bad:
                w("| `%s` | %s | `%s` | %d | %d |\n" % (b, k, e, got, want))
            w("\n")
        else:
            w("**No disagreements.** Every `end` in §3 that NT exercises is\n"
              "correct, including the `@modrm8 + p.osz*8` forms where both\n"
              "terms vary.\n\n")
        w("## Coverage\n\n")
        tot = dyn_cov + dyn_unc
        w("| | distinct encodings | executed |\n|---|---:|---:|\n")
        w("| reach an arm | %d | %s |\n" % (covered, f"{dyn_cov:,}"))
        w("| fall through to `_` | %d | %s |\n" % (n - covered, f"{dyn_unc:,}"))
        w("\n%.1f%% of executed instructions land on an arm.\n\n"
          % (100.0 * dyn_cov / tot if tot else 0))
        w("The l8 file is a deliberate subset, so a non-empty gap list is\n"
          "expected; it is the list of arms the file would have to grow to\n"
          "decode a Windows NT boot.\n\n")
        w("### Missing arms, by variant and addressing mode\n\n")
        w("| variant | modrm kind | distinct encodings |\n|---|---|---:|\n")
        for (v, k), c in sorted(uncovered.items(), key=lambda x: -x[1])[:60]:
            w("| %s | %s | %d |\n" % (v, k, c))
        w("\n### The one that is not a subset decision\n\n")
        w("`lea` is spelled out per addressing mode in §3 — `base_d8`,\n"
          "`base_d32`, `sib_d32`, `abs32`, plus `reg_direct` as #UD. NT also\n"
          "executes `lea` with `sib_base`, `sib_d8`, `sib_abs`, `base`,\n"
          "`base16_d8`, `base16_d16` and `abs16`. Those arms are missing rather\n"
          "than omitted: the enumeration is over the *same* nine names §1\n"
          "declares, so the gap is visible by inspection, which is the\n"
          "property §5.2 claims for arm-local extents.\n")


if __name__ == "__main__":
    main()
