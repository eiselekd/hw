#!/usr/bin/env python3
"""Verify the l8 decoder against every instruction a boot executed.

Implements M1 of ~/git/l8/test/decode_x86_verify.md: the offline sweep.

    corpus (every executed encoding shape, from the l8trace build)
        -> scope classification (the limited decoder claims mode 32, no prefixes)
        -> reference decode        iced-x86 (positions via ConstantOffsets)
        -> expected l8 decode      the mini-decoder transcription that also
                                   generates decode_x86_limited_tb.l8sim
                                   (imported from --l8dir, single source)
        -> synthetic instances     disp/imm bytes rewritten with position-
                                   identifying and sign-boundary patterns
        -> l8i                     report-mode chunks, print-based, no aborts
        -> compare                 variant + every bound field
        -> registry                <db>/<target>.l8_failures.jsonl
        -> repros                  <l8dir>/repro/fail_<bytes>.l8sim

Classes (decode_x86_verify.md §2): out_of_scope/{mode16,prefix,uncovered-op},
expect_mismatch (transcription disagrees with iced -- an expectation bug, not
an l8 bug), variant / field / error (real l8 findings), agree.

Usage (via `make l8verify-winnt L8I=...` in x86/decode, or directly):

    .venv/bin/python tools/l8_verify.py --target winnt \
        --l8i ~/git/l8/use/interpreter/l8i --l8dir ~/git/l8/test
"""

import argparse
import datetime
import importlib.util
import json
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter, defaultdict

from iced_x86 import Decoder, Formatter, FormatterSyntax, Code

HERE = os.path.dirname(os.path.abspath(__file__))
X86 = os.path.dirname(HERE)

PREFIXES = {0x26, 0x2E, 0x36, 0x3E, 0x64, 0x65, 0x66, 0x67, 0xF0, 0xF2, 0xF3}

# args whose value comes from disp/imm bytes (compared against iced);
# everything else (w, opreg, cc, ...) is opcode-structural.
VALUE_ARGS = {"imm", "imm8", "imm16", "immz", "rel", "rel8", "moffs", "ptr",
              "base"}

# ---------------------------------------------------------------- expected

def load_gen(l8dir):
    """Import the mini-decoder from the l8 repo (single source of truth for
    the transcription of decode_x86_limited.l8)."""
    p = os.path.join(l8dir, "gen_decode_x86_limited_tb.py")
    spec = importlib.util.spec_from_file_location("l8gen", p)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


FMT = Formatter(FormatterSyntax.NASM)

def iced_decode(bs):
    """-> (length, text, disp_val, [imm_vals]) or None if invalid."""
    dec = Decoder(32, bytes(bs))
    ins = dec.decode()
    if ins.code == Code.INVALID or ins.len > len(bs):
        return None
    co = dec.get_constant_offsets(ins)
    disp = None
    if co.displacement_size > 0:
        o, n = co.displacement_offset, co.displacement_size
        disp = int.from_bytes(bs[o:o+n], "little")
    imms = []
    if co.immediate_size > 0:
        o, n = co.immediate_offset, co.immediate_size
        imms.append(int.from_bytes(bs[o:o+n], "little"))
    if co.immediate_size2 > 0:
        o, n = co.immediate_offset2, co.immediate_size2
        imms.append(int.from_bytes(bs[o:o+n], "little"))
    return ins.len, FMT.format(ins), disp, imms, co


def expect_check(d, iced):
    """Compare the transcription's value-bearing fields against iced's
    disp/imm extraction.  Returns None if they agree, else a description."""
    _, _, disp, imms, _ = iced
    mine = []
    for k, v in d.args.items():
        if k in VALUE_ARGS:
            mine.append(v)
    ref = list(imms)
    if d.mfields.get("disp") is not None:
        mine.append(d.mfields["disp"])
    if disp is not None:
        ref.append(disp)
    if "ptr" in d.args:
        # far pointer: the l8 layout is one 48-bit field; iced reports the
        # offset+selector halves separately, or (for some codes) not at all
        # in ConstantOffsets -- in that case there is nothing to check the
        # pointer against and it is dropped from the comparison.
        mine.remove(d.args["ptr"])
        if len(imms) == 2:
            mine.append(d.args["ptr"])
            ref = [imms[0] | (imms[1] << 32)]
        else:
            ref = []
        if disp is not None:
            ref.append(disp)
    if sorted(mine) != sorted(ref):
        return f"values l8={sorted(mine)} iced={sorted(ref)}"
    return None


# ---------------------------------------------------------------- synthetic

def mutants(bs, iced):
    """Position-identifying and sign-boundary rewrites of the disp/imm bytes
    (decode_x86_verify.md §3.1b).  Key bytes are never touched, so the shape
    -- and therefore the decode path -- is unchanged by construction."""
    length, _, _, _, co = iced
    spans = []
    if co.displacement_size > 0:
        spans.append((co.displacement_offset, co.displacement_size))
    if co.immediate_size > 0:
        spans.append((co.immediate_offset, co.immediate_size))
    if co.immediate_size2 > 0:
        spans.append((co.immediate_offset2, co.immediate_size2))
    if not spans:
        return []
    POS = [0xA1, 0xB2, 0xC3, 0xD4, 0xE5, 0xF6, 0x17, 0x28, 0x39, 0x4A]
    out = []
    for name, fill in (("pos", None), ("ones", 0xFF), ("sign", None)):
        m = bytearray(bs)
        i = 0
        for off, size in spans:
            for j in range(size):
                if name == "pos":
                    m[off + j] = POS[(i + j) % len(POS)]
                elif name == "ones":
                    m[off + j] = 0xFF
                else:  # sign: MSB 0x80, rest 0
                    m[off + j] = 0x80 if j == size - 1 else 0x00
            i += size
        out.append((name, bytes(m)))
    return out


# ---------------------------------------------------------------- chunks

def bus_expr(bs):
    # 7-byte groups: l8i hex literals are i64, so a literal >= 2^63 goes
    # NEGATIVE and corrupts the | / << arithmetic.  56-bit chunks never can.
    parts = []
    for i in range(0, len(bs), 7):
        chunk = int.from_bytes(bs[i:i+7], "little")
        if chunk or not parts:
            parts.append(f"0x{chunk:X}" if i == 0
                         else f"(0x{chunk:X} << {i*8})")
    return " | ".join(parts)


def emit_block(tid, bs, d, out):
    """One report-mode block: prints verdicts, never aborts (verify.md §3.1)."""
    out.append(f"bus = {bus_expr(bs)}")
    binds = list(d.args.keys())
    if d.mname:
        binds.append(d.mname)
    head = f"    {d.variant}" + (f".({', '.join(binds)})" if binds else "")
    out.append("b.decode {")
    out.append(head + ": {")
    out.append(f'        print("V {tid} 1")')
    for k in d.args:
        out.append(f'        print("F {tid} {k} ", {k})')
    if d.mname:
        kb = [k for k in ("mod", "reg", "rm", "r", "b", "x", "s", "disp")
              if k in d.mfields]
        out.append(f"        {d.mname}.decode {{")
        out.append(f"            {d.mkind}.({', '.join(kb)}): {{")
        out.append(f'                print("K {tid} 1")')
        for k in kb:
            out.append(f'                print("F {tid} m.{k} ", {k})')
        out.append("            }")
        out.append(f'            _: {{ print("K {tid} 0") }}')
        out.append("        }")
    out.append("    }")
    out.append(f'    _: {{ print("V {tid} 0") }}')
    out.append("}")
    out.append("")


def run_chunk(l8i, decoder_path, items, tmpdir):
    """items: list of (tid, bytes, Dec).  Returns {tid: report-dict} or None
    on interpreter failure (caller bisects)."""
    out = [f'include "{decoder_path}"', "", "bus : [std;128] = 0",
           "b = x86l(bus)", ""]
    for tid, bs, d in items:
        emit_block(tid, bs, d, out)
    path = os.path.join(tmpdir, f"chunk_{items[0][0]}.l8sim")
    with open(path, "w") as f:
        f.write("\n".join(out) + "\n")
    r = subprocess.run([l8i, path], capture_output=True, text=True,
                       timeout=600)
    if r.returncode != 0:
        return None
    # V/K lines carry a 0/1 flag, F lines a named field value
    rep = defaultdict(dict)
    for line in r.stdout.splitlines():
        t = line.strip().split()
        if not t or t[0] not in ("V", "K", "F"):
            continue
        if t[0] == "V" and len(t) == 3:
            rep[int(t[1])]["V"] = t[2] == "1"
        elif t[0] == "K" and len(t) == 3:
            rep[int(t[1])]["K"] = t[2] == "1"
        elif t[0] == "F" and len(t) == 4:
            rep[int(t[1])].setdefault("F", {})[t[2]] = int(t[3])
    return rep


def run_all(l8i, decoder_path, items, tmpdir, chunk, errors):
    """Run in chunks; bisect failing chunks down to the offending sample."""
    results = {}
    queue = [items[i:i+chunk] for i in range(0, len(items), chunk)]
    while queue:
        part = queue.pop()
        rep = run_chunk(l8i, decoder_path, part, tmpdir)
        if rep is not None:
            results.update(rep)
            continue
        if len(part) == 1:
            errors.append(part[0])
            continue
        mid = len(part) // 2
        queue.append(part[:mid])
        queue.append(part[mid:])
    return results


def compare(d, rep):
    """-> (cls, detail) with cls in agree|variant|field."""
    if rep is None or "V" not in rep:
        return "error", "no report line"
    if not rep["V"]:
        return "variant", f"expected {d.variant}, decoder matched something else"
    diffs = []
    got = rep.get("F", {})
    for k, v in d.args.items():
        g = got.get(k)
        if g != v:
            diffs.append(f"{k}: expect {v:#x} got {g if g is None else hex(g)}")
    if d.mname:
        if not rep.get("K"):
            return "field", f"modrm kind: expected {d.mkind}"
        for k in ("mod", "reg", "rm", "r", "b", "x", "s", "disp"):
            if k in d.mfields:
                g = got.get("m." + k)
                if g != d.mfields[k]:
                    diffs.append(f"{d.mname}.{k}: expect {d.mfields[k]:#x} "
                                 f"got {g if g is None else hex(g)}")
    if diffs:
        return "field", "; ".join(diffs)
    return "agree", ""


# ---------------------------------------------------------------- registry

def load_registry(path):
    reg = {}
    if os.path.exists(path):
        for line in open(path):
            line = line.strip()
            if not line:
                continue
            e = json.loads(line)
            reg[(e["bytes"], e.get("pattern"))] = e
    return reg


def save_registry(path, reg):
    entries = sorted(reg.values(),
                     key=lambda e: (-int(e.get("count", 0)), e["bytes"]))
    with open(path, "w") as f:
        for e in entries:
            f.write(json.dumps(e) + "\n")


def register(reg, key, today, rev, **fields):
    e = reg.get(key)
    if e is None:
        e = {"bytes": key[0], "pattern": key[1], "status": "new",
             "first_seen": today}
        reg[key] = e
    else:
        # a previously fixed entry that fails again is a regression
        if e.get("status") == "fixed" and fields.get("class") != "agree":
            e["status"] = "new"
    e.update(fields)
    e["last_seen"] = today
    e["decoder_rev"] = rev
    return e


# ---------------------------------------------------------------- repro

def write_repro(gen, l8dir, bs, hexbytes, pattern, d, text):
    rdir = os.path.join(l8dir, "repro")
    os.makedirs(rdir, exist_ok=True)
    suff = f"_{pattern}" if pattern else ""
    path = os.path.join(rdir, f"fail_{hexbytes}{suff}.l8sim")
    out = [f"# repro: {hexbytes}{suff}  {text}",
           "# generated by x86/tools/l8_verify.py -- run: l8i " +
           os.path.basename(path),
           f'include "{os.path.join(l8dir, "decode_x86_limited.l8")}"', "",
           "bus : [std;128] = 0", "b = x86l(bus)", ""]
    row = {"bytes": bs.hex(), "text": text}
    gen.emit_test(0, row, d, out)
    out.append('print("repro: ok")')
    with open(path, "w") as f:
        f.write("\n".join(out) + "\n")
    return path


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--target", default="winnt")
    ap.add_argument("--corpus", help="override corpus path")
    ap.add_argument("--l8i", required=True, help="path to the l8i interpreter")
    ap.add_argument("--l8dir", default=os.path.expanduser("~/git/l8/test"),
                    help="l8 repo test dir (decode_x86_limited.l8, generator)")
    ap.add_argument("--registry", help="failures JSONL (default: next to corpus)")
    ap.add_argument("--chunk", type=int, default=500)
    ap.add_argument("--no-synthetic", action="store_true")
    ap.add_argument("--limit", type=int, default=0, help="first N corpus entries")
    args = ap.parse_args()

    db = os.path.join(X86, args.target, "instructions", "decoded_database")
    corpus = args.corpus or os.path.join(db, f"{args.target}.corpus.jsonl")
    registry_path = args.registry or os.path.join(
        db, f"{args.target}.l8_failures.jsonl")
    l8i = os.path.abspath(os.path.expanduser(args.l8i))
    l8dir = os.path.abspath(os.path.expanduser(args.l8dir))
    decoder_path = os.path.join(l8dir, "decode_x86_limited.l8")
    for p, what in ((l8i, "l8i"), (decoder_path, "decoder"), (corpus, "corpus")):
        if not os.path.exists(p):
            sys.exit(f"l8_verify: {what} not found: {p}")

    gen = load_gen(l8dir)
    try:
        rev = subprocess.run(["git", "-C", l8dir, "rev-parse", "--short", "HEAD"],
                             capture_output=True, text=True).stdout.strip() or "?"
    except OSError:
        rev = "?"
    today = datetime.date.today().isoformat()

    reg = load_registry(registry_path)
    stats = Counter()
    weighted = Counter()

    # ---- pass 1: classify + build the l8i work list --------------------
    work = []          # (tid, window_bytes, Dec, meta)
    entries = [json.loads(l) for l in open(corpus)]
    if args.limit:
        entries = entries[:args.limit]
    tid = 0
    seen_insn = set()
    for e in entries:
        for hexs in e["bytes"]:
            window = bytes.fromhex(hexs)
            if not window:
                continue
            meta = {"count": e.get("count", 0), "phase": e.get("phase")}

            if e["mode"] != 32:
                stats["out_of_scope/mode16"] += 1
                weighted["out_of_scope/mode16"] += meta["count"]
                register(reg, (hexs, None), today, rev,
                         mode=e["mode"], **meta,
                         **{"class": "out_of_scope/mode16"},
                         status="out_of_scope")
                continue
            if window[0] in PREFIXES:
                stats["out_of_scope/prefix"] += 1
                weighted["out_of_scope/prefix"] += meta["count"]
                register(reg, (hexs, None), today, rev, mode=32, **meta,
                         **{"class": "out_of_scope/prefix"},
                         status="out_of_scope")
                continue

            iced = iced_decode(window)
            if iced is None:
                # a sample the reference cannot decode: page-boundary cuts
                # (the corpus marks the entry `truncated`, or the sample is
                # visibly short) are expected; a full window iced rejects
                # would be a real anomaly.
                if e.get("truncated") or len(window) < 15:
                    stats["out_of_scope/truncated"] += 1
                    register(reg, (hexs, None), today, rev, mode=32, **meta,
                             **{"class": "out_of_scope/truncated"},
                             status="out_of_scope")
                else:
                    stats["iced_invalid"] += 1
                    register(reg, (hexs, None), today, rev, mode=32, **meta,
                             **{"class": "iced_invalid"}, status="new")
                continue
            length, text, _, _, _ = iced
            insn = window[:length]
            if insn.hex() in seen_insn:
                continue
            seen_insn.add(insn.hex())

            try:
                d = gen.decode(window)
            except IndexError:
                d = None
            if d is None:
                stats["out_of_scope/uncovered-op"] += 1
                weighted["out_of_scope/uncovered-op"] += meta["count"]
                register(reg, (insn.hex(), None), today, rev, mode=32, **meta,
                         **{"class": "out_of_scope/uncovered-op"},
                         status="out_of_scope", text=text)
                continue

            bad = expect_check(d, iced)
            if bad:
                stats["expect_mismatch"] += 1
                register(reg, (insn.hex(), None), today, rev, mode=32, **meta,
                         **{"class": "expect_mismatch"}, status="new",
                         text=text, detail=bad,
                         expect={"variant": d.variant, "args": d.args})
                continue

            work.append((tid, window, d,
                         dict(meta, insn=insn.hex(), pattern=None, text=text)))
            tid += 1

            if not args.no_synthetic:
                for pname, mut in mutants(window, iced):
                    ic2 = iced_decode(mut)
                    if ic2 is None or ic2[0] != length:
                        continue
                    try:
                        d2 = gen.decode(mut)
                    except IndexError:
                        continue
                    if d2 is None or d2.variant != d.variant:
                        continue        # mutation escaped the shape: skip
                    bad = expect_check(d2, ic2)
                    if bad:
                        stats["expect_mismatch"] += 1
                        register(reg, (mut[:length].hex(), pname), today, rev,
                                 mode=32, count=meta["count"],
                                 phase=meta["phase"],
                                 **{"class": "expect_mismatch"}, status="new",
                                 detail=bad, synthetic=True)
                        continue
                    work.append((tid, mut, d2,
                                 dict(meta, insn=mut[:length].hex(),
                                      pattern=pname, text=ic2[1])))
                    tid += 1

    # ---- pass 2: run l8i ----------------------------------------------
    errors = []
    with tempfile.TemporaryDirectory(prefix="l8verify_") as tmpdir:
        results = run_all(l8i, decoder_path,
                          [(t, b, d) for t, b, d, _ in work],
                          tmpdir, args.chunk, errors)

    err_ids = {t for t, _, _ in errors}
    fail_n = 0
    for t, window, d, meta in work:
        key = (meta["insn"], meta["pattern"])
        if t in err_ids:
            cls, detail = "error", "l8i failed on this input (chunk bisect)"
        else:
            cls, detail = compare(d, results.get(t))
        tag = "synthetic/" if meta["pattern"] else ""
        stats[tag + cls] += 1
        if not meta["pattern"]:
            weighted[cls] += meta["count"]
        if cls == "agree":
            if key in reg and reg[key].get("status") not in ("fixed",
                                                            "out_of_scope"):
                register(reg, key, today, rev, **{"class": "agree"},
                         status="fixed")
            continue
        fail_n += 1
        e = register(reg, key, today, rev, mode=32, count=meta["count"],
                     phase=meta["phase"], **{"class": cls}, detail=detail,
                     text=meta["text"],
                     expect={"variant": d.variant, "args": d.args,
                             "modrm": ({"name": d.mname, "kind": d.mkind,
                                        **d.mfields} if d.mname else None)},
                     **({"synthetic": True} if meta["pattern"] else {}))
        e["repro"] = write_repro(gen, l8dir, window, meta["insn"],
                                 meta["pattern"], d, meta["text"])

    save_registry(registry_path, reg)

    # ---- summary -------------------------------------------------------
    print(f"l8_verify [{args.target}] decoder rev {rev}")
    print(f"  corpus entries: {len(entries)}, distinct instructions: "
          f"{len(seen_insn)}, l8i runs: {len(work)}")
    for k in sorted(stats):
        w = f"  (weight {weighted[k]})" if weighted.get(k) else ""
        print(f"  {k:28s} {stats[k]:6d}{w}")
    open_fail = [e for e in reg.values()
                 if e.get("status") in ("new", "examined")
                 and e.get("class") not in ("agree",)]
    print(f"  registry: {registry_path}")
    print(f"  open failures: {len(open_fail)}")
    for e in sorted(open_fail, key=lambda e: -int(e.get("count", 0)))[:15]:
        print(f"    {e['bytes']:20s} {e.get('class',''):16s} "
              f"{e.get('text','')[:40]:40s} {e.get('detail','')[:60]}")
    sys.exit(1 if any(stats[c] for c in ("variant", "field", "error",
                                         "expect_mismatch")) else 0)


if __name__ == "__main__":
    main()
