#!/usr/bin/env bash
# End-to-end ISA census for one target.
#
#   ./run.sh win98            # fetch image, boot, count, aggregate, annotate
#   ./run.sh winnt            # same for Windows NT 4.0
#   ./run.sh winnt --seconds 300 --shots
#   ./run.sh --all
#
# Everything is driven by x86/targets.json; results land in
#   x86/<target>/traces/        raw counter dumps + phase snapshots (gitignored)
#   x86/<target>/instructions/  hist.tsv, isa.txt, isa.json, coverage.md (tracked)
#   x86/<target>/shots/         boot screenshots (tracked)
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
X86_DIR=$(cd "$HERE/.." && pwd)
V86_DIR=$X86_DIR/decoders/v86

if [[ ${1:-} == --all ]]; then
    shift
    for t in $(python3 -c "
import json; print(' '.join(json.load(open('$X86_DIR/targets.json'))['targets']))
"); do
        "$HERE/run.sh" "$t" "$@" || echo "!! $t failed" >&2
    done
    exit 0
fi

target=${1:-win98}
shift || true

# ------------------------------------------------------------------ 0. build
if [[ ! -f $V86_DIR/build/v86.wasm || ! -f $V86_DIR/build/libv86-debug.mjs ]]; then
    echo "== building instrumented v86"
    # `clang` may only exist as clang-N; shim it if needed
    if ! command -v clang >/dev/null; then
        mkdir -p /tmp/shim
        ln -sf "$(command -v clang-14 || command -v clang-15)" /tmp/shim/clang
        export PATH=/tmp/shim:$PATH
    fi
    make -C "$V86_DIR" with-win98stats
    make -C "$V86_DIR" build/libv86-debug.mjs
fi

# ------------------------------------------------------------------ 1. image
echo "== [$target] image"
"$HERE/fetch_image.sh" "$target"
"$HERE/fetch_image.sh" "$target" state || true

# ------------------------------------------------------------------ 2. census
out=$X86_DIR/$target/traces/$target.boot.tsv
mkdir -p "$(dirname "$out")"

# targets that define a scripted logon need it, or the census stops at the
# "press Ctrl+Alt+Del" prompt and never sees the shell
login=
if python3 -c "
import json,sys
t=json.load(open('$X86_DIR/targets.json'))['targets']['$target']
sys.exit(0 if t.get('login') else 1)
"; then login=--login; fi

# census_node.mjs stops itself after `seconds`, but a wedged emulator (or a
# guest that never reaches the logon prompt) would otherwise hang `make`
# forever, so put a hard watchdog around it: the configured boot time plus a
# 180 s margin for image load, state restore and the final counter dump.
# Overridable with CENSUS_TIMEOUT=<seconds>.
secs=$(python3 -c "
import json,sys
argv=sys.argv[1:]
t=json.load(open('$X86_DIR/targets.json'))['targets']['$target']
s=t.get('boot_seconds',60)
if '--seconds' in argv: s=int(argv[argv.index('--seconds')+1])
print(s)
" "$@")
watchdog=${CENSUS_TIMEOUT:-$(( secs + 180 ))}

echo "== [$target] cold boot census $login -> $out (${secs}s, watchdog ${watchdog}s)"
if ! timeout --foreground -k 20 "$watchdog" \
        node "$HERE/census_node.mjs" --target "$target" --screen $login --out "$out" "$@" </dev/null
then
    rc=$?
    # 124 = watchdog fired.  Any phase snapshot already on disk is still
    # usable, so fall through to aggregation instead of failing the build.
    if [[ $rc == 124 || $rc == 137 ]]; then
        echo "!! [$target] census hit the ${watchdog}s watchdog; aggregating partial counters" >&2
    else
        echo "!! [$target] census failed (exit $rc)" >&2
        exit $rc
    fi
fi

if ! compgen -G "$X86_DIR/$target/traces/*.tsv" >/dev/null; then
    echo "!! [$target] no counter dumps produced" >&2
    exit 1
fi

# ------------------------------------------------------------------ 3. aggregate
# The phase*.tsv files are running snapshots of the same counters, so they must
# be merged with --cumulative (max per encoding), never summed.
inst=$X86_DIR/$target/instructions
mkdir -p "$inst"
echo "== [$target] aggregate"
python3 "$HERE/aggregate.py" --cumulative "$X86_DIR/$target/traces/"*.tsv \
    -o "$inst/$target.hist.tsv" \
    --title "$target boot" \
    --coverage "$inst/$target.coverage.md" \
    --opcodes  "$inst/$target.opcodes.txt"

# ------------------------------------------------------------------ 4. annotate
echo "== [$target] annotate"
python3 "$HERE/annotate.py" "$inst/$target.hist.tsv" \
    --title "$target" \
    -o "$inst/$target.isa.txt" \
    --json "$inst/$target.isa.json"

echo "== [$target] done"
ls -l "$inst"
