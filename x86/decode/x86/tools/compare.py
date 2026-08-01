#!/usr/bin/env python3
"""Compare the ISA censuses of two or more targets.

  ./compare.py win98 winnt
  ./compare.py --all -o ../COMPARISON.md

Answers the question the whole exercise exists for: which encodings does a
decoder need to support, and does that set actually change between guests?
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
X86 = HERE.parent


def key(e: dict) -> tuple:
    """Identity of an encoding: what a decoder must distinguish."""
    ext = e["opcode_ext"]
    ext = "" if ext is None else str(ext)
    return (e["mode"], e["opcode"], ext, e["modrm_form"] or "")


def label(k: tuple) -> str:
    mode, op, ext, form = k
    return f"{mode:>2}b {op}{' ' + ext if ext else ''}{' [' + form + ']' if form else ''}"


def load(target: str) -> dict:
    p = X86 / target / "instructions" / f"{target}.isa.json"
    if not p.exists():
        sys.exit(f"no census for '{target}': {p}\n  run: ./run.sh {target}")
    out = {}
    for e in json.load(open(p)):
        # unresolved/#UD entries carry no reference annotation
        e.setdefault("since", "?")
        e.setdefault("group", "?")
        e.setdefault("mnemonic", "?")
        out[key(e)] = e
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("targets", nargs="*")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("-o", "--out", type=Path)
    a = ap.parse_args()

    targets = a.targets
    if a.all:
        reg = json.load(open(X86 / "targets.json"))["targets"]
        targets = [t for t in reg
                   if (X86 / t / "instructions" / f"{t}.isa.json").exists()]
    if len(targets) < 2:
        sys.exit("need at least two targets with a census")

    sets = {t: load(t) for t in targets}
    out = []
    w = out.append

    w("# Instruction set comparison\n")
    w("| target | instructions executed | distinct encodings | mnemonics |")
    w("|---|---:|---:|---:|")
    for t, s in sets.items():
        total = sum(e["count"] for e in s.values())
        mnem = len({e["mnemonic"] for e in s.values()})
        w(f"| {t} | {total:,} | {len(s):,} | {mnem} |")
    w("")

    union = set().union(*(s.keys() for s in sets.values()))
    common = set.intersection(*(set(s.keys()) for s in sets.values()))
    w(f"union of all targets: **{len(union)}** encodings")
    w(f"common to all targets: **{len(common)}** encodings\n")

    # pairwise, only meaningful for exactly two
    if len(targets) == 2:
        x, y = targets
        sx, sy = sets[x], sets[y]
        only_x = sorted(set(sx) - set(sy), key=lambda k: -sx[k]["count"])
        only_y = sorted(set(sy) - set(sx), key=lambda k: -sy[k]["count"])

        for name, only, src in ((x, only_x, sx), (y, only_y, sy)):
            other = y if name == x else x
            w(f"## Only in {name} ({len(only)}), not in {other}\n")
            w("| encoding | mnemonic | since | count | group |")
            w("|---|---|---|---:|---|")
            for k in only[:60]:
                e = src[k]
                w(f"| `{label(k)}` | {e['mnemonic']} | {e['since']} | "
                  f"{e['count']:,} | {e['group']} |")
            if len(only) > 60:
                w(f"\n... and {len(only) - 60} more\n")
            w("")

    # CPU generation breakdown
    w("## Encodings by introducing CPU\n")
    gens = sorted({e["since"] for s in sets.values() for e in s.values()})
    w("| CPU | " + " | ".join(targets) + " |")
    w("|---|" + "---:|" * len(targets))
    for g in gens:
        row = [str(sum(1 for e in sets[t].values() if e["since"] == g)) for t in targets]
        w(f"| {g} | " + " | ".join(row) + " |")
    w("")

    # anything newer than the 386 is what really constrains a decoder
    w("## Post-80386 encodings\n")
    w("| encoding | mnemonic | since | " + " | ".join(targets) + " |")
    w("|---|---|---|" + "---:|" * len(targets))
    old = {"8086", "80186", "80286", "80386", ""}
    post = sorted((k for k in union
                   if any(k in s and s[k]["since"] not in old for s in sets.values())),
                  key=lambda k: next(s[k]["mnemonic"] for s in sets.values() if k in s))
    for k in post:
        e = next(s[k] for s in sets.values() if k in s)
        counts = [f"{sets[t][k]['count']:,}" if k in sets[t] else "-" for t in targets]
        w(f"| `{label(k)}` | {e['mnemonic']} | {e['since']} | " + " | ".join(counts) + " |")
    w("")

    text = "\n".join(out)
    if a.out:
        a.out.write_text(text)
        print(f"[+] {a.out}")
    else:
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
