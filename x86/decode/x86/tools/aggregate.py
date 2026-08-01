#!/usr/bin/env python3
"""Aggregate raw x86 execution traces into an opcode usage histogram.

Input line formats accepted (auto-detected, tab or whitespace separated):

  1. counter dumps   :  <count>\t<mode>\t<opcode-hex>\t<ext>\t<mnemonic>
  2. raw traces      :  <mode>\t<mnemonic>\t<opcode-hex>[\t<modrm-hex>][\t<eip>]
  3. objdump-ish     :  addr: <hex bytes>  <mnemonic> <operands>

Output: sorted TSV histogram + optional coverage report + opcode list.

Usage:
  aggregate.py traces/*.tsv -o instructions/win98.hist.tsv \
      --coverage instructions/win98.coverage.md \
      --opcodes  instructions/win98.opcodes.txt
"""
from __future__ import annotations

import argparse
import gzip
import re
import sys
from collections import Counter
from pathlib import Path

HEX = re.compile(r"^[0-9A-Fa-f]{2}(?:[ _]?[0-9A-Fa-f]{2})*$")
OBJDUMP = re.compile(r"^\s*[0-9a-f]+:\s+((?:[0-9a-f]{2} )+)\s*(\S+)(.*)$")


def norm_opcode(s: str) -> str:
    """Normalize '0f_af' / '0F AF' / '0faf' -> '0F AF'."""
    s = s.replace("_", " ").strip()
    if " " not in s:
        s = " ".join(s[i:i + 2] for i in range(0, len(s), 2))
    return s.upper()


def opener(p: Path):
    return gzip.open(p, "rt") if p.suffix == ".gz" else open(p, "rt", errors="replace")


def parse(path: Path, hist: Counter) -> None:
    for line in opener(path):
        line = line.rstrip("\n")
        if not line or line.startswith("#"):
            continue

        m = OBJDUMP.match(line)
        if m:
            hist[("?", norm_opcode(m.group(1)), "", m.group(2).lower(), "")] += 1
            continue

        f = line.split("\t") if "\t" in line else line.split()
        if not f:
            continue

        # form 1: leading integer count.  The optional 6th column is r|m, which
        # distinguishes register-form from memory-form encodings of the same
        # opcode -- they have different layouts, so it belongs in the key.
        if f[0].isdigit() and len(f) >= 5:
            cnt, mode, op, ext, mnem = int(f[0]), f[1], f[2], f[3], f[4]
            rm = f[5].strip() if len(f) > 5 else ""
            hist[(mode, norm_opcode(op), ext.strip("-"), mnem.lower(), rm)] += cnt
            continue

        # form 2
        if len(f) >= 3 and f[0] in ("16", "32", "64", "?"):
            mode, mnem, op = f[0], f[1], f[2]
            modrm = f[3] if len(f) > 3 and HEX.match(f[3]) else ""
            ext = ""
            rm = ""
            if modrm:
                try:
                    b = int(modrm[:2], 16)
                    ext = "/%d" % ((b >> 3) & 7)
                    rm = "r" if (b >> 6) == 3 else "m"
                except ValueError:
                    ext = ""
            hist[(mode, norm_opcode(op), ext, mnem.lower(), rm)] += 1
            continue

        print(f"warn: unparsed line in {path}: {line[:80]!r}", file=sys.stderr)


def write_hist(hist: Counter, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w") as fh:
        fh.write("#count\tmode\topcode\text\tmnemonic\trm\n")
        for (mode, op, ext, mnem, rm), c in hist.most_common():
            fh.write(f"{c}\t{mode}\t{op}\t{ext or '-'}\t{mnem}\t{rm or '-'}\n")


def write_coverage(hist: Counter, out: Path, title: str = "boot") -> None:
    total = sum(hist.values()) or 1
    rows, acc = [], 0
    for i, (_k, c) in enumerate(hist.most_common(), 1):
        acc += c
        rows.append((i, acc / total))
    marks = [0.50, 0.90, 0.99, 0.999, 0.9999, 1.0]
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w") as fh:
        fh.write(f"# {title} opcode coverage\n\n")
        fh.write(f"total executed instructions: {total:,}\n")
        fh.write(f"distinct encodings: {len(hist):,}\n\n")
        fh.write("| coverage | #encodings needed |\n|---|---|\n")
        for m in marks:
            n = next((i for i, p in rows if p >= m - 1e-12), len(rows))
            fh.write(f"| {m*100:g} % | {n} |\n")


def write_opcodes(hist: Counter, out: Path) -> None:
    seen = sorted({(op, ext, mnem) for (_m, op, ext, mnem, _rm) in hist})
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w") as fh:
        for op, ext, mnem in seen:
            fh.write(f"{op}\t{ext or '-'}\t{mnem}\n")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("traces", nargs="+", type=Path)
    ap.add_argument("-o", "--out", type=Path, required=True)
    ap.add_argument("--coverage", type=Path)
    ap.add_argument("--opcodes", type=Path)
    ap.add_argument("--title", default="boot")
    ap.add_argument("--cumulative", action="store_true",
                    help="inputs are running snapshots of the same counters "
                         "(census_node.mjs --phase-every), so take the maximum "
                         "per encoding instead of the sum")
    a = ap.parse_args()

    hist: Counter = Counter()
    if a.cumulative:
        for p in a.traces:
            snap: Counter = Counter()
            parse(p, snap)
            for k, v in snap.items():
                if v > hist[k]:
                    hist[k] = v
    else:
        for p in a.traces:
            parse(p, hist)

    write_hist(hist, a.out)
    if a.coverage:
        write_coverage(hist, a.coverage, a.title)
    if a.opcodes:
        write_opcodes(hist, a.opcodes)

    print(f"{sum(hist.values()):,} instructions, {len(hist):,} distinct encodings -> {a.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
