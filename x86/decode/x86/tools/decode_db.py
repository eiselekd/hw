#!/usr/bin/env python3
"""Turn v86's raw encoding corpus into the decoded instruction database.

    x86/winnt/instructions/decoded_database/winnt.corpus.jsonl   (in)
        one line per encoding shape, up to two full 16-byte samples each
    x86/winnt/instructions/decoded_database/winnt.decoded.jsonl  (out)
    x86/winnt/instructions/decoded_database/winnt.decoded.tsv    (out)
    x86/winnt/instructions/decoded_database/README.md            (out)

TWO DECODERS, ON PURPOSE
------------------------
Every record is produced twice and the two are required to agree:

  * a STRUCTURAL decode written here (`structural()`): prefix run, opcode,
    modrm, sib, displacement position and width -- i.e. exactly the fields a
    bit-level decoder description has to get right, computed the way such a
    description computes them, from nothing but the bytes.

  * iced-x86, a reference decoder validated against the full Intel opcode map,
    which supplies instruction length, mnemonic, operand list and the
    *semantic* view of the memory operand (base/index/scale/displacement).

The structural side never looks at an opcode table for immediate widths; it
takes the total length from iced and reports the remainder as the immediate.
So `len` is iced's, everything else is independently derived, and the `ok`
column says whether they agreed.  A database with `ok=1` everywhere is one
whose structural fields are known-good, which is what makes it usable as an
oracle for another decoder.

Needs:  python3 -m venv .venv && .venv/bin/pip install iced-x86
"""

import argparse
import glob
import json
import os
import sys
from collections import Counter, defaultdict

try:
    from iced_x86 import (Decoder, Formatter, FormatterSyntax, Instruction,
                          Mnemonic, OpKind, Register)
except ImportError:
    sys.exit("iced-x86 missing:  python3 -m venv .venv && "
             ".venv/bin/pip install iced-x86   (then run with .venv/bin/python)")

# ---------------------------------------------------------------- constants

PREFIXES = {0x26, 0x2E, 0x36, 0x3E, 0x64, 0x65, 0x66, 0x67, 0xF0, 0xF2, 0xF3}
SEG_PREFIX = {0x26: "es", 0x2E: "cs", 0x36: "ss", 0x3E: "ds",
              0x64: "fs", 0x65: "gs"}
REP_PREFIX = {0xF2: "repnz", 0xF3: "rep"}

R32 = ["eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi"]
R16 = ["ax", "cx", "dx", "bx", "sp", "bp", "si", "di"]
R8 = ["al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"]
# 16-bit addressing r/m -> (base, index)
RM16 = [("bx", "si"), ("bx", "di"), ("bp", "si"), ("bp", "di"),
        ("si", None), ("di", None), ("bp", None), ("bx", None)]

# Opcodes with a modrm byte.  Same table as the emulator-side l8trace.rs, and
# the two are checked against each other by construction: if this disagreed,
# the header length would disagree and `ok` would go to 0.
def has_modrm(is_0f, op):
    if is_0f:
        return (op <= 0x03 or op in (0x0D, 0x0F) or 0x10 <= op <= 0x2F
                or 0x40 <= op <= 0x77 or 0x7C <= op <= 0x7F
                or 0x90 <= op <= 0x9F or 0xA3 <= op <= 0xA5
                or 0xAB <= op <= 0xAF or 0xB0 <= op <= 0xB7 or op == 0xB8
                or 0xBA <= op <= 0xBF or 0xC0 <= op <= 0xC7
                or 0xD0 <= op <= 0xFE)
    return (op <= 0x03 or 0x08 <= op <= 0x0B or 0x10 <= op <= 0x13
            or 0x18 <= op <= 0x1B or 0x20 <= op <= 0x23 or 0x28 <= op <= 0x2B
            or 0x30 <= op <= 0x33 or 0x38 <= op <= 0x3B
            or op in (0x62, 0x63, 0x69, 0x6B)
            or 0x80 <= op <= 0x8F or op in (0xC0, 0xC1)
            or 0xC4 <= op <= 0xC7 or 0xD0 <= op <= 0xD3
            or 0xD8 <= op <= 0xDF or op in (0xF6, 0xF7, 0xFE, 0xFF))


# Group opcodes: modrm.reg is an opcode extension, not a register.
def has_fixed_g(is_0f, op):
    if is_0f:
        return op in (0x00, 0x01, 0x18, 0x1F, 0x71, 0x72, 0x73,
                      0xAE, 0xBA, 0xC7) or 0x90 <= op <= 0x9F
    return (0x80 <= op <= 0x83 or op == 0x8F or op in (0xC0, 0xC1, 0xC6, 0xC7)
            or 0xD0 <= op <= 0xD3 or 0xD8 <= op <= 0xDF
            or op in (0xF6, 0xF7, 0xFE, 0xFF))


# ---------------------------------------------------------------- structural

def structural(b, mode):
    """Decode the shape of `b` (bytes) in 16- or 32-bit mode.

    Returns a dict, or raises ValueError if the sample is too short.  Nothing
    here consults an instruction table beyond `has_modrm`: everything is
    positional, which is the point -- these are the fields to be compared.
    """
    n = len(b)
    i = 0
    pfx = []
    while i < 4 and i < n and b[i] in PREFIXES:
        pfx.append(b[i])
        i += 1
    if i >= n:
        raise ValueError("truncated in prefixes")

    has66 = 0x66 in pfx
    has67 = 0x67 in pfx
    seg = next((SEG_PREFIX[p] for p in pfx if p in SEG_PREFIX), None)
    rep = next((REP_PREFIX[p] for p in pfx if p in REP_PREFIX), None)
    lock = 0xF0 in pfx

    mode32 = mode == 32
    osz = 2 if (mode32 == has66) else 4      # 4 in 32-bit unless 0x66
    asz = 2 if (mode32 == has67) else 4

    at = i                                    # the anchor: opcode byte index
    is_0f = b[i] == 0x0F
    if is_0f:
        i += 1
        if i >= n:
            raise ValueError("truncated after 0F")
    op = b[i]
    i += 1

    rec = {
        "mode": mode,
        "pfx": {"n": len(pfx), "bytes": "".join("%02x" % p for p in pfx),
                "osz": osz, "asz": asz, "seg": seg, "rep": rep, "lock": lock},
        "at": at,
        "is0f": is_0f,
        "op": "0f%02x" % op if is_0f else "%02x" % op,
        "modrm": None,
        "fixed_g": None,
    }

    if not has_modrm(is_0f, op):
        rec["hdr"] = i
        rec["disp_bits"] = 0
        rec["disp_at"] = None
        return rec

    if i >= n:
        raise ValueError("truncated before modrm")
    modrm = b[i]
    modrm_at = i
    i += 1
    md, reg, rm = modrm >> 6, (modrm >> 3) & 7, modrm & 7

    sib = None
    sib_at = None
    if asz == 4 and md != 3 and rm == 4:
        if i >= n:
            raise ValueError("truncated before sib")
        sib = b[i]
        sib_at = i
        i += 1

    # Displacement width and position follow from (mod, rm, sib.base) alone.
    if asz == 4:
        if md == 0:
            disp_bits = 32 if (rm == 5 or (rm == 4 and (sib & 7) == 5)) else 0
        elif md == 1:
            disp_bits = 8
        elif md == 2:
            disp_bits = 32
        else:
            disp_bits = 0
    else:
        if md == 0:
            disp_bits = 16 if rm == 6 else 0
        elif md == 1:
            disp_bits = 8
        elif md == 2:
            disp_bits = 16
        else:
            disp_bits = 0

    disp_at = i if disp_bits else None
    if disp_bits and i + disp_bits // 8 > n:
        raise ValueError("truncated in displacement")
    disp = None
    if disp_bits:
        w = disp_bits // 8
        disp = int.from_bytes(b[i:i + w], "little", signed=True)
        i += w

    # The nine memory-operand shapes, named as the bit-level description names
    # them.  This partition over (mod, rm, sib.base) is the thing most worth
    # verifying, so it is spelled out rather than derived from iced.
    m = {"mod": md, "reg": reg, "rm": rm, "at": modrm_at,
         "b": None, "x": None, "s": None,
         "disp": disp, "disp_bits": disp_bits, "disp_at": disp_at,
         "sib": None, "sib_at": sib_at, "extent": i - modrm_at}
    if sib is not None:
        m["sib"] = {"base": sib & 7, "index": (sib >> 3) & 7, "scale": sib >> 6}

    if md == 3:
        kind = "reg_direct"
        m["r"] = rm
    elif asz == 2:
        if md == 0 and rm == 6:
            kind = "abs16"
        else:
            kind = {0: "base16", 1: "base16_d8", 2: "base16_d16"}[md]
        m["b16"], m["x16"] = RM16[rm] if kind != "abs16" else (None, None)
    elif rm != 4:
        if md == 0:
            kind = "abs32" if rm == 5 else "base"
            m["b"] = None if rm == 5 else rm
        else:
            kind = "base_d8" if md == 1 else "base_d32"
            m["b"] = rm
    else:
        m["b"] = sib & 7
        m["x"] = (sib >> 3) & 7
        m["s"] = sib >> 6
        if md == 0 and (sib & 7) == 5:
            kind = "sib_abs"
            m["b"] = None
        elif md == 0:
            kind = "sib_base"
        elif md == 1:
            kind = "sib_d8"
        else:
            kind = "sib_d32"
    m["kind"] = kind
    # `index == 4` means NO index register -- a sentinel, not register 4.
    if m["x"] == 4:
        m["x"] = None

    rec["modrm"] = m
    rec["hdr"] = modrm_at + (2 if sib is not None else 1)
    rec["disp_bits"] = disp_bits
    rec["disp_at"] = disp_at
    rec["end_of_disp"] = i
    if has_fixed_g(is_0f, op):
        rec["fixed_g"] = reg
    return rec


# ---------------------------------------------------------------- reference

REGNAME = {v: k.lower() for k, v in vars(Register).items()
           if isinstance(v, int) and not k.startswith("_")}
OPKIND = {v: k for k, v in vars(OpKind).items()
          if isinstance(v, int) and not k.startswith("_")}


def ref_decode(b, mode, fmt):
    d = Decoder(mode, bytes(b), ip=0)
    ins = d.decode()
    if ins.code == 0 or ins.len == 0:          # Code.INVALID
        return None
    ops = []
    for k in range(ins.op_count):
        ok = ins.op_kind(k)
        if ok == OpKind.REGISTER:
            ops.append("r:" + REGNAME.get(ins.op_register(k), "?"))
        elif ok == OpKind.MEMORY:
            ops.append("m")
        elif ok in (OpKind.IMMEDIATE8, OpKind.IMMEDIATE8_2ND,
                    OpKind.IMMEDIATE16, OpKind.IMMEDIATE32,
                    OpKind.IMMEDIATE8TO16, OpKind.IMMEDIATE8TO32):
            ops.append("i:0x%x" % ins.immediate(k))
        elif ok in (OpKind.NEAR_BRANCH16, OpKind.NEAR_BRANCH32):
            ops.append("rel:0x%x" % ins.near_branch_target)
        elif ok in (OpKind.FAR_BRANCH16, OpKind.FAR_BRANCH32):
            ops.append("far")
        else:
            ops.append(OPKIND.get(ok, str(ok)).lower())
    return {
        "len": ins.len,
        "text": fmt.format(ins),
        "mnemonic": REGNAME.get(-1) or fmt.format(ins).split()[0],
        "ops": ops,
        "mem_base": REGNAME.get(ins.memory_base, None)
                    if ins.memory_base else None,
        "mem_index": REGNAME.get(ins.memory_index, None)
                     if ins.memory_index else None,
        "mem_scale": ins.memory_index_scale,
        "mem_disp": ins.memory_displacement,
        "mem_disp_size": ins.memory_displ_size,
        "mem_seg": REGNAME.get(ins.memory_segment, None),
    }


# ---------------------------------------------------------------- cross-check

def cross_check(s, r):
    """Compare the structural decode against iced.  Returns a list of
    disagreements; empty means the record is trustworthy."""
    bad = []
    m = s["modrm"]
    if m is None:
        return bad
    if m["kind"] == "reg_direct":
        if r["mem_base"] or r["mem_index"]:
            bad.append("reg_direct but iced has a memory operand")
        return bad
    if r["mem_base"] is None and r["mem_index"] is None and r["mem_disp"] == 0:
        # no memory operand at all: LEA-less register forms, or an opcode whose
        # modrm addresses something iced models differently (e.g. LDS/LES).
        return bad

    if s["pfx"]["asz"] == 4:
        exp_b = R32[m["b"]] if m["b"] is not None else None
        exp_x = R32[m["x"]] if m["x"] is not None else None
        if r["mem_base"] != exp_b:
            bad.append("base %s != iced %s" % (exp_b, r["mem_base"]))
        if r["mem_index"] != exp_x:
            bad.append("index %s != iced %s" % (exp_x, r["mem_index"]))
        if exp_x is not None and r["mem_scale"] != 1 << m["s"]:
            bad.append("scale %d != iced %d" % (1 << m["s"], r["mem_scale"]))
    if m["disp_bits"]:
        # iced reports the displacement sign-extended to the address size.
        mask = 0xFFFFFFFF if s["pfx"]["asz"] == 4 else 0xFFFF
        if (m["disp"] & mask) != (r["mem_disp"] & mask):
            bad.append("disp 0x%x != iced 0x%x" % (m["disp"] & mask,
                                                   r["mem_disp"] & mask))
    if m["disp_bits"] != r["mem_disp_size"] * 8 and r["mem_disp_size"]:
        bad.append("disp_bits %d != iced %d" % (m["disp_bits"],
                                                r["mem_disp_size"] * 8))
    return bad


# ---------------------------------------------------------------- main

def build(corpus_paths, out_dir, max_variants=2):
    fmt = Formatter(FormatterSyntax.NASM)
    fmt.hex_prefix, fmt.hex_suffix = "0x", ""
    fmt.space_after_operand_separator = True

    seen = {}                # (mode, canonical bytes) -> record (final dedup)
    stats = Counter()
    problems = []

    # Phase files are CUMULATIVE (the emulator never clears the shape table),
    # so the last file is the whole boot.  Reading them in order lets us record
    # the first phase in which each encoding appeared, which is the only
    # information the earlier files carry that the last one does not -- so they
    # can then be deleted instead of kept.
    for phase, path in enumerate(corpus_paths, 1):
        last = phase == len(corpus_paths)
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                e = json.loads(line)
                mode = e["mode"]
                count = int(e["count"])
                for hx in e["bytes"][:max_variants]:
                    raw = bytes.fromhex(hx)
                    if not last:
                        # earlier phases only contribute the phase label
                        r = ref_decode(raw, mode, fmt)
                        if r is None:
                            continue
                        k = (mode, raw[:r["len"]])
                        if count and k not in stats_first:
                            stats_first[k] = phase
                        continue
                    stats["samples"] += 1
                    r = ref_decode(raw, mode, fmt)
                    if r is None:
                        # Almost always a sample the emulator cut short at a
                        # page boundary, not a real undecodable instruction.
                        stats["page_truncated" if len(raw) < 15
                              else "undecodable"] += 1
                        problems.append((mode, hx, "iced: invalid (%d bytes)"
                                         % len(raw)))
                        continue
                    b = raw[:r["len"]]
                    key = (mode, b)
                    if key in seen:
                        seen[key]["count"] += count
                        continue
                    try:
                        s = structural(b, mode)
                    except ValueError as ex:
                        stats["truncated"] += 1
                        problems.append((mode, hx, "structural: %s" % ex))
                        continue

                    # Immediate = whatever iced's length leaves after the
                    # fields this file located positionally.  No opcode table
                    # needed, which is the point: the immediate's *position* is
                    # structural, only its width comes from the reference.
                    after = s.get("end_of_disp", s["hdr"])
                    imm_bits = (r["len"] - after) * 8
                    imm = None
                    if imm_bits > 0:
                        imm = int.from_bytes(b[after:r["len"]], "little")
                    bad = cross_check(s, r)
                    if imm_bits < 0:
                        bad.append("structural fields overrun iced length")
                    stats["mismatch" if bad else "ok"] += 1

                    rec = dict(s)
                    rec["bytes"] = b.hex()
                    rec["len"] = r["len"]
                    rec["imm"] = imm
                    rec["imm_bits"] = max(imm_bits, 0)
                    rec["imm_at"] = after if imm_bits > 0 else None
                    rec["text"] = r["text"]
                    rec["ops"] = r["ops"]
                    rec["count"] = count
                    rec["shape"] = "%d:%s" % (mode, hx[:s["hdr"] * 2])
                    rec["phase"] = stats_first.get(key, phase)
                    rec["ok"] = not bad
                    if bad:
                        rec["disagree"] = bad
                    seen[key] = rec

    recs = sorted(seen.values(), key=lambda x: -x["count"])
    os.makedirs(out_dir, exist_ok=True)

    with open(os.path.join(out_dir, "winnt.decoded.jsonl"), "w") as f:
        for r in recs:
            f.write(json.dumps(r, separators=(",", ":")) + "\n")

    write_tsv(os.path.join(out_dir, "winnt.decoded.tsv"), recs)
    write_readme(os.path.join(out_dir, "README.md"), recs, stats, problems)
    return recs, stats, problems


stats_first = {}


def field_str(r):
    """Every located field as `name@bitoffset:width=value`, which is the form a
    bit-level decoder can be diffed against directly."""
    out = []
    p = r["pfx"]
    if p["n"]:
        out.append("pfx@0:%d=%s" % (p["n"] * 8, p["bytes"]))
    out.append("op@%d:%d=%s" % (r["at"] * 8, 16 if r["is0f"] else 8, r["op"]))
    m = r["modrm"]
    if m:
        out.append("mod@%d:2=%d" % (m["at"] * 8 + 6, m["mod"]))
        out.append("reg@%d:3=%d" % (m["at"] * 8 + 3, m["reg"]))
        out.append("rm@%d:3=%d" % (m["at"] * 8, m["rm"]))
        if m["sib"]:
            o = m["sib_at"] * 8
            out.append("base@%d:3=%d" % (o, m["sib"]["base"]))
            out.append("index@%d:3=%d" % (o + 3, m["sib"]["index"]))
            out.append("scale@%d:2=%d" % (o + 6, m["sib"]["scale"]))
        if m["disp_bits"]:
            out.append("disp@%d:%d=%d" % (m["disp_at"] * 8, m["disp_bits"],
                                          m["disp"]))
    if r["imm_bits"]:
        out.append("imm@%d:%d=0x%x" % (r["imm_at"] * 8, r["imm_bits"],
                                       r["imm"]))
    return " ".join(out)


TSV_HEADER = ("count\tshape\tphase\tmode\tbytes\tlen\tosz\tasz\tseg\trep\tpfxn\top\tfixg\t"
              "kind\tmod\treg\trm\tb\tx\ts\tdisp\tdispbits\tmodrmbits\t"
              "imm\timmbits\tok\ttext\tfields\n")


def write_tsv(path, recs):
    with open(path, "w") as f:
        f.write(TSV_HEADER)
        for r in recs:
            m = r["modrm"] or {}
            p = r["pfx"]
            f.write("\t".join(str(x) for x in [
                r["count"], r.get("shape", "-"), r.get("phase", "-"),
                r["mode"], r["bytes"], r["len"],
                p["osz"], p["asz"], p["seg"] or "-", p["rep"] or "-", p["n"],
                r["op"], "-" if r["fixed_g"] is None else r["fixed_g"],
                m.get("kind", "-"),
                m.get("mod", "-"), m.get("reg", "-"), m.get("rm", "-"),
                "-" if m.get("b") is None else m["b"],
                "-" if m.get("x") is None else m["x"],
                "-" if m.get("s") is None else m["s"],
                "-" if m.get("disp") is None else m["disp"],
                m.get("disp_bits", 0), m.get("extent", 0) * 8,
                "-" if r["imm"] is None else "0x%x" % r["imm"], r["imm_bits"],
                1 if r["ok"] else 0,
                r["text"], field_str(r),
            ]) + "\n")


def write_readme(path, recs, stats, problems):
    total = sum(r["count"] for r in recs)
    by_kind = Counter(r["modrm"]["kind"] for r in recs if r["modrm"])
    kind_dyn = defaultdict(int)
    for r in recs:
        if r["modrm"]:
            kind_dyn[r["modrm"]["kind"]] += r["count"]
    by_mode = Counter(r["mode"] for r in recs)
    ops = Counter(r["op"] for r in recs)
    bad = [r for r in recs if not r["ok"]]

    with open(path, "w") as f:
        w = f.write
        w("# Decoded instruction database — Windows NT 4.0 boot\n\n")
        w("Generated by `x86/tools/decode_db.py` from the deduplicated encoding\n"
          "corpus that an instrumented v86 collects during a live NT boot\n"
          "(`x86/decoders/v86/src/rust/l8trace.rs`, feature `l8trace`).\n\n")
        w("Each row is a **distinct instruction byte string** that Windows NT\n"
          "actually executed, decoded into its constituent fields with their\n"
          "bit offsets, so another decoder can be diffed against it field by\n"
          "field rather than by mnemonic.\n\n")
        w("## Files\n\n")
        w("| file | content |\n|---|---|\n")
        w("| `winnt.corpus.jsonl` | raw corpus from the emulator: encoding shape -> up to 2 sample byte strings + execution count |\n")
        w("| `winnt.decoded.jsonl` | one JSON record per distinct byte string, all fields |\n")
        w("| `winnt.decoded.tsv` | the same, flat; the `fields` column is `name@bitoffset:width=value` |\n")
        w("| `winnt.l8_expect.csv` | the l8 test vector: bytes in -> expected `decode(d)` arm, bound arguments and `end` (produced by `x86/tools/l8_expect.py`) |\n")
        w("| `winnt.l8_gaps.md` | which encodings the l8 arm list does not yet cover, and the `end` verdict |\n\n")
        w("The `.csv` is column-aligned with spaces so it reads as a table; it\n"
          "is still valid CSV (`csv.reader(f, skipinitialspace=True)`), the\n"
          "values just need `.strip()`.\n\n")
        w("## Size\n\n")
        w("%d distinct byte strings covering %s executed instructions.\n\n"
          % (len(recs), f"{total:,}"))
        w("`count` belongs to the **encoding shape** (`shape` column), not to\n"
          "the individual byte string: the emulator counts shapes and keeps up\n"
          "to two byte strings per shape as displacement/immediate samples, so\n"
          "two rows sharing a `shape` each report that shape's total and the\n"
          "figure above double-counts them.  Use `count` as a ranking within a\n"
          "shape-deduplicated view; for exact dynamic frequencies see the\n"
          "caveat at the end.\n\n")
        w("## Validation\n\n")
        w("Every record is decoded twice — a positional/structural decode\n"
          "written from the bytes alone, and iced-x86 — and the two are\n"
          "required to agree on base/index/scale, displacement value and\n"
          "width, and total length.\n\n")
        w("| | |\n|---|---|\n")
        for k in ("samples", "ok", "mismatch", "page_truncated", "undecodable"):
            w("| %s | %d |\n" % (k, stats[k]))
        w("\n`page_truncated` are samples the emulator cut short at a page\n"
          "boundary (it will not translate a second page just to trace), not\n"
          "instructions NT failed to execute.\n\n")
        if bad:
            w("### Disagreements (%d)\n\n" % len(bad))
            for r in bad[:40]:
                w("- `%s` (%d-bit) %s — %s\n"
                  % (r["bytes"], r["mode"], r["text"], "; ".join(r["disagree"])))
            w("\n")
        w("## Coverage of the addressing-mode partition\n\n")
        w("This is the axis a bit-level decoder's modrm arms partition on, so\n"
          "it is the axis on which the database has to be complete.\n\n")
        w("| modrm kind | distinct encodings | executed |\n|---|---:|---:|\n")
        for k, n in by_kind.most_common():
            w("| %s | %d | %s |\n" % (k, n, f"{kind_dyn[k]:,}"))
        w("\n## Modes\n\n| mode | distinct encodings |\n|---|---:|\n")
        for m, n in sorted(by_mode.items()):
            w("| %d-bit | %d |\n" % (m, n))
        by_phase = Counter(r.get("phase", 0) for r in recs)
        w("\n## First appearance, by boot phase (60 s each)\n\n")
        w("An encoding counted in phase *n* was executed for the first time in\n"
          "that phase, so this shows the ISA surface growing: firmware and the\n"
          "real-mode loader first, then the kernel, then the GUI.\n\n")
        w("| phase | new encodings |\n|---:|---:|\n")
        for p, n in sorted(by_phase.items()):
            w("| %s | %d |\n" % (p, n))
        w("\n## Distinct opcodes\n\n%d.\n\n" % len(ops))
        w("## Hottest 30 shapes\n\n")
        w("| count | mode | bytes | text |\n|---:|---|---|---|\n")
        shown = set()
        for r in recs:
            if r.get("shape") in shown:
                continue
            shown.add(r.get("shape"))
            w("| %s | %d | `%s` | `%s` |\n"
              % (f"{r['count']:,}", r["mode"], r["bytes"], r["text"]))
            if len(shown) >= 30:
                break
        w("\n## Caveat: the JIT path\n\n")
        w("The corpus is collected on v86's **interpreter** path. v86 only\n"
          "compiles a block after it has been interpreted enough times to get\n"
          "hot, so every executed encoding passes through the interpreter at\n"
          "least once and the *set* of encodings is complete; the `count`\n"
          "column, however, undercounts hot code by the compiled fraction.\n"
          "Counts are therefore a ranking, not a census — for exact dynamic\n"
          "frequencies use `winnt.hist.tsv`, which also instruments the JIT.\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    here = os.path.dirname(os.path.abspath(__file__))
    default_dir = os.path.join(here, "..", "winnt", "instructions",
                               "decoded_database")
    ap.add_argument("--corpus", nargs="*", default=None,
                    help="corpus JSONL files in phase order; "
                         "default: <out-dir>/winnt.corpus[.phaseN].jsonl")
    ap.add_argument("--out-dir", default=default_dir)
    ap.add_argument("--max-variants", type=int, default=2)
    ap.add_argument("--clean", action="store_true",
                    help="delete the per-phase corpus files afterwards: they "
                         "are cumulative prefixes of the final one and their "
                         "only unique content, the first-appearance phase, is "
                         "folded into the database")
    a = ap.parse_args()

    paths = a.corpus
    if not paths:
        ph = sorted(glob.glob(os.path.join(a.out_dir, "winnt.corpus.phase*.jsonl")),
                    key=lambda p: int(p.rsplit("phase", 1)[1].split(".")[0]))
        final = os.path.join(a.out_dir, "winnt.corpus.jsonl")
        paths = ph + ([final] if os.path.exists(final) else [])
        if not paths:
            sys.exit("no corpus found in %s" % a.out_dir)
    print("corpus: " + ", ".join(os.path.basename(p) for p in paths))

    recs, stats, problems = build(paths, a.out_dir, a.max_variants)
    print("%d distinct byte strings, %d ok, %d mismatch, %d page-truncated, "
          "%d undecodable" % (len(recs), stats["ok"], stats["mismatch"],
                              stats["page_truncated"], stats["undecodable"]))
    for p in problems[:10]:
        print("  %d-bit %s: %s" % p)

    if a.clean:
        for p in paths[:-1]:
            os.remove(p)
        print("removed %d per-phase corpus files" % (len(paths) - 1))


if __name__ == "__main__":
    main()
