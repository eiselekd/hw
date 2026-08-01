#!/usr/bin/env python3
"""Annotate an instruction census with mnemonics and encoding layouts.

Joins the histogram produced by census_node.mjs / aggregate.py against the
x86asm.net reference XML (x86/decoders/x86asm-net/x86reference.xml), which is
also the source v86's own decode table was derived from.

  ./annotate.py ../win98/instructions/win98.hist.tsv \
      -o ../win98/instructions/win98.isa.txt \
      --json ../win98/instructions/win98.isa.json

Input columns (aggregate.py "form 1", optional 6th mem/reg column):
  count  mode  opcode  ext  mnemonic  [r|m]
"""
from __future__ import annotations

import argparse
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEFAULT_XML = HERE / ".." / "decoders" / "x86asm-net" / "x86reference.xml"

# <proc_start> code -> CPU that introduced the encoding
PROC = {
    "00": "8086", "01": "80186", "02": "80286", "03": "80386", "04": "80486",
    "05": "P1", "06": "P1MMX", "07": "PPro", "08": "P2", "09": "P3",
    "10": "P4", "11": "Core", "12": "Core2", "13": "i7", "99": "later",
}

# addressing method (<a>) -> readable operand kind
ADDR = {
    "A": "far-ptr", "BA": "m(seg:rBX+AL)", "BB": "m(seg:rBX)",
    "BD": "m(DS:rDI)", "C": "CRn", "D": "DRn", "E": "r/m", "ES": "st/m",
    "EST": "st(i)", "F": "eflags", "G": "reg", "H": "reg(vex)", "I": "imm",
    "J": "rel", "M": "mem", "N": "mm/r", "O": "moffs", "P": "mm", "Q": "mm/m",
    "R": "r(mod=11)", "S": "sreg", "SC": "stack", "T": "TRn", "U": "xmm/r",
    "V": "xmm", "W": "xmm/m", "X": "m(DS:rSI)", "Y": "m(ES:rDI)",
    "Z": "reg(in-opcode)",
}

# operand type (<t>) -> size
TYPE = {
    "a": "2x16/2x32", "b": "8", "bcd": "bcd", "bs": "8sx", "bss": "8sx",
    "d": "32", "da": "32", "di": "i32", "do": "f64", "dq": "128", "dqa": "128",
    "dqp": "32/64", "dr": "f64", "ds": "f32", "e": "fpuenv", "er": "f80",
    "p": "16:16/16:32", "pi": "mm64", "pd": "f64x2", "ps": "f32x4",
    "psq": "f32x2", "pt": "16:64", "ptp": "16:32/16:64",
    "q": "64", "qa": "64", "qi": "i64", "qp": "64", "s": "6/10",
    "sd": "f64", "si": "i32", "sr": "f32", "ss": "f32", "st": "fpustate",
    "stx": "fpu+simd-state", "v": "16/32", "vds": "16/32sx", "vq": "64/16",
    "vqp": "16/32", "vs": "16/32", "w": "16", "wa": "16", "wi": "i16",
    "wo": "16", "ws": "16", "x": "128/256", "y": "32/64", "z": "16/32",
}


def _operand(op: ET.Element) -> str:
    a = op.findtext("a")
    t = op.findtext("t")
    if a is None and t is None:
        txt = (op.text or "").strip()          # literal, e.g. <dst>AL</dst>
        return txt or (op.get("nr") or "")
    kind = ADDR.get(a, a or "")
    size = TYPE.get(t, t or "")
    return f"{kind}{size}" if size else kind


def _syntax(entry: ET.Element):
    """-> (mnemonic | None, operand string)"""
    syn = entry.find("syntax")
    if syn is None:
        return None, ""
    mnem = (syn.findtext("mnem") or "").strip()
    if not mnem:
        return None, ""
    ops = []
    for op in syn:
        if op.tag not in ("dst", "src") or op.get("displayed") == "no":
            continue
        s = _operand(op)
        if s:
            ops.append(s)
    return mnem, ", ".join(ops)


def load_reference(xml_path: Path) -> dict:
    """-> dict[(is0f, opcode, ext|None)] -> list[record]

    Note: x86reference.xml lists "register in opcode" instructions (PUSH r32,
    POP r32, INC r32, DEC r32, XCHG eAX,r32, MOV r8/r32,imm) only at the *base*
    opcode; the encoding actually covers base..base+7.  Those entries are
    recognised by the `Z` addressing method and expanded here.
    """
    root = ET.parse(xml_path).getroot()
    table: dict = {}
    plus_r: dict = {}
    # opcodes the reference explicitly documents as invalid/undefined in 32-bit
    # mode -- executing them raises #UD, which is a legitimate thing for code to
    # do on purpose (0F FF is UD0, 0F BA /0../3 are reserved in the BT group).
    invalid: set = set()
    listed: set = set()          # every (is0f, opcode) the reference mentions
    for section in root:
        if section.tag not in ("one-byte", "two-byte"):
            continue
        is0f = section.tag == "two-byte"
        for pri in section.findall("pri_opcd"):
            opcode = int(pri.get("value"), 16)
            listed.add((is0f, opcode))
            for entry in pri.findall("entry"):
                if entry.get("attr") in ("invd", "undef"):
                    if entry.get("mode") != "e":
                        invalid.add((is0f, opcode))
                    continue
                if entry.get("mode") == "e":          # 64-bit only
                    continue
                mnem, ops = _syntax(entry)
                if mnem is None:
                    continue
                ext = entry.findtext("opcd_ext")
                syn = entry.find("syntax")
                is_plus_r = any(op.findtext("a") == "Z" for op in syn
                                if op.tag in ("dst", "src"))
                rec = {
                    "mnemonic": mnem,
                    "operands": ops,
                    # x86reference.xml omits <proc_start> for the oldest entries
                    # in each table.  For the one-byte table that means 8086,
                    # but the 0F escape byte itself only exists from the 80286
                    # on, so a missing proc_start there means 80286 -- not 8086.
                    # Without this, LLDT/LTR/LGDT/LIDT/SIDT/SLDT/STR/SMSW/LMSW/
                    # VERR/VERW all get mis-attributed to the 8086.
                    "since": PROC.get(entry.findtext("proc_start")
                                      or ("02" if is0f else "00"), "?"),
                    "flags_modified": entry.findtext("modif_f") or "-",
                    "flags_undefined": entry.findtext("undef_f") or "",
                    "group": "/".join(x for x in (entry.findtext("grp1"),
                                                  entry.findtext("grp2"),
                                                  entry.findtext("grp3")) if x),
                    "brief": entry.findtext("note/brief") or "",
                    "lock": entry.get("lock") == "yes",
                    "modrm": entry.get("r") == "yes" or ext is not None,
                    "opcd_ext": int(ext) if ext is not None else None,
                    "ring0": entry.get("ring") == "0",
                    "plus_r": is_plus_r,
                }
                table.setdefault((is0f, opcode, rec["opcd_ext"]), []).append(rec)
                if is_plus_r:
                    for n in range(1, 8):
                        plus_r.setdefault((is0f, opcode + n, rec["opcd_ext"]), []).append(rec)

    for key, recs in plus_r.items():
        table.setdefault(key, []).extend(recs)

    # An opcode with a modrm extension but no entry for this particular /n is a
    # reserved encoding, e.g. 0F BA /0.
    decodable = {(is0f, op) for (is0f, op, _e) in table}
    return table, invalid, decodable, listed


def lookup(table, is0f, opcode, ext):
    # ext -> exact match; then the no-extension entry; then ext 0, which the
    # reference uses for opcodes that have a modrm byte with a fixed reg field
    # (8F /0 POP, C6 /0 MOV, 0F 9x /0 SETcc).
    return (table.get((is0f, opcode, ext))
            or table.get((is0f, opcode, None))
            or table.get((is0f, opcode, 0))
            or [])


def parse_hist(path: Path):
    rows = []
    for line in open(path):
        if not line.strip() or line.startswith("#"):
            continue
        f = line.rstrip("\n").split("\t")
        if len(f) < 5 or not f[0].isdigit():
            continue
        op, ext = f[2].strip(), f[3].strip()
        rows.append(dict(
            count=int(f[0]),
            mode=f[1],
            raw=op,
            is0f=op.upper().startswith("0F"),
            opcode=int(op.split()[-1], 16),
            ext=int(ext[1:]) if ext.startswith("/") else None,
            memreg=f[5].strip() if len(f) > 5 else "",
        ))
    rows.sort(key=lambda r: -r["count"])
    return rows


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("hist", type=Path)
    ap.add_argument("-o", "--out", type=Path)
    ap.add_argument("--json", type=Path)
    ap.add_argument("--xml", type=Path, default=DEFAULT_XML)
    ap.add_argument("--title", default=None,
                    help="census name for the header; defaults to the input "
                         "file's stem (e.g. win98, winnt)")
    a = ap.parse_args()

    if not a.xml.exists():
        print(f"missing {a.xml}\nrun: x86/decoders/fetch.sh x86asm-net", file=sys.stderr)
        return 1

    table, invalid, decodable, listed = load_reference(a.xml)
    rows = parse_hist(a.hist)
    total = sum(r["count"] for r in rows) or 1

    hdr = (f"{'count':>13} {'%':>7} {'md':>3} {'opcode':<6} {'ext':<4} "
           f"{'m/r':<4} {'mnemonic':<10} {'operands':<30} {'since':<6} flags")
    title = a.title or a.hist.name.split(".")[0]
    lines = [
        f"# {title} instruction census: {len(rows)} distinct encodings, "
        f"{total:,} instructions executed",
        f"# layout source: {a.xml.name} (ref.x86asm.net)",
        "#",
        "# " + hdr,
    ]
    out_json, unresolved, n_invalid = [], [], 0
    for r in rows:
        cands = lookup(table, r["is0f"], r["opcode"], r["ext"])
        best = cands[0] if cands else None
        key = (r["is0f"], r["opcode"])
        note = ""
        if best is None:
            # Every one of these raises #UD; distinguish *why* so a genuine bug
            # in this joiner is not silently reported as "invalid".
            if key in decodable:
                note = "reserved slot in opcode group"
            elif key in invalid:
                note = "documented as invalid in 32-bit mode"
            elif key not in listed:
                note = "undocumented opcode (e.g. UD0)"
            else:
                note = "UNRESOLVED - check annotate.py"
                unresolved.append(r["raw"] +
                                  (f"/{r['ext']}" if r["ext"] is not None else ""))
            if not unresolved or unresolved[-1] != r["raw"]:
                n_invalid += 1
        mnem = best["mnemonic"] if best else "(#UD)"
        pct = 100.0 * r["count"] / total
        lines.append(
            f"{r['count']:>13} {pct:7.4f} {r['mode']:>3} {r['raw']:<6} "
            f"{('/' + str(r['ext'])) if r['ext'] is not None else '-':<4} "
            f"{r['memreg'] or '-':<4} {mnem:<10} "
            f"{(best['operands'] if best else note):<30} "
            f"{(best['since'] if best else ''):<6} "
            f"{(best['flags_modified'] if best else '-')}")
        rec = {
            "count": r["count"],
            "share_percent": round(pct, 6),
            "mode": int(r["mode"]),
            "opcode": r["raw"],
            "opcode_ext": r["ext"],
            "modrm_form": {"m": "mem", "r": "reg"}.get(r["memreg"], "any"),
            "mnemonic": mnem,
        }
        if best:
            rec.update({k: best[k] for k in
                        ("operands", "since", "flags_modified", "flags_undefined",
                         "group", "brief", "modrm", "lock", "ring0")})
            rec["alternatives"] = [c["mnemonic"] for c in cands[1:]]
        else:
            rec["invalid"] = True
            rec["invalid_reason"] = note
        rec["layout_source"] = "ref.x86asm.net"
        out_json.append(rec)

    txt = "\n".join(lines) + "\n"
    if a.out:
        a.out.parent.mkdir(parents=True, exist_ok=True)
        a.out.write_text(txt)
        print(f"[+] {a.out}", file=sys.stderr)
    else:
        sys.stdout.write(txt)
    if a.json:
        a.json.parent.mkdir(parents=True, exist_ok=True)
        a.json.write_text(json.dumps(out_json, indent=1))
        print(f"[+] {a.json}", file=sys.stderr)

    print(f"{len(out_json)} encodings, {n_invalid} invalid (#UD), "
          f"{len(unresolved)} unresolved"
          + (": " + ", ".join(unresolved[:20]) if unresolved else ""), file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
