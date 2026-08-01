#!/usr/bin/env bash
# Fetch the exact disk images that the hosted v86 demo (copy.sh/v86) uses.
#
#   ./fetch_image.sh win98         -> ../win98/images/windows98.img
#   ./fetch_image.sh win98 state   -> also the boot-to-desktop snapshot
#   ./fetch_image.sh winnt         -> ../winnt/images/winnt4.img
#   ./fetch_image.sh --list
#
# All image metadata lives in x86/targets.json (copied from
# v86/src/browser/main.js); note the remote directory name usually differs from
# the target id.
#
# v86 serves these as fixed 256 KB parts named
#     https://i.copy.sh/<remote>/<offset>-<offset+chunk>.img
# (see AsyncXHRPartfileBuffer in v86/src/buffer.js).  The browser only pulls the
# chunks it touches; for repeated headless runs it is much better to reassemble
# the whole image once.
set -euo pipefail

HOST=${HOST:-https://i.copy.sh}
JOBS=${JOBS:-16}
HERE=$(cd "$(dirname "$0")" && pwd)
X86_DIR=$(cd "$HERE/.." && pwd)
REGISTRY=$X86_DIR/targets.json

if [[ ${1:-} == --list || -z ${1:-} ]]; then
    python3 -c "
import json
t = json.load(open('$REGISTRY'))['targets']
print(f\"{'target':<10} {'name':<18} {'size':>8}  state\")
for k, v in t.items():
    i = v['image']
    print(f\"{k:<10} {v['name']:<18} {i['size']//1024//1024:>5} MB  {'yes' if i.get('state') else '-'}\")
"
    exit 0
fi

name=$1
want_state=${2:-}

# pull all four fields in one python call
read -r remote file size state < <(python3 -c "
import json, sys
t = json.load(open('$REGISTRY'))['targets']
if '$name' not in t:
    sys.stderr.write(\"unknown target '$name'; try --list\n\"); sys.exit(1)
i = t['$name']['image']
print(i['remote'], i['file'], i['size'], i.get('state') or '-')
")

OUT_DIR=${OUT_DIR:-$X86_DIR/$name/images}
chunk=$((256 * 1024))
parts=$(( (size + chunk - 1) / chunk ))
work=$OUT_DIR/.parts-$name
img=$OUT_DIR/$file

mkdir -p "$work"

if [[ -f $img && $(stat -c%s "$img") -eq $size ]]; then
    echo "== $img already complete"
else
    echo "== fetching $parts parts of $remote -> $img ($((size / 1024 / 1024)) MB) with $JOBS jobs"
    seq 0 $((parts - 1)) | xargs -P "$JOBS" -I{} bash -c '
        i=$1; chunk=$2; work=$3; host=$4; remote=$5
        off=$((i * chunk)); end=$((off + chunk))
        f=$work/$(printf "%08d" "$i").part
        [[ -s $f ]] && exit 0
        curl -fsS --retry 5 --retry-delay 2 -o "$f" "$host/$remote/$off-$end.img" \
            || { echo "FAILED part $i" >&2; exit 1; }
    ' _ {} "$chunk" "$work" "$HOST" "$remote"

    echo "== concatenating"
    cat "$work"/*.part > "$img"
    truncate -s "$size" "$img"
    rm -rf "$work"
fi

ls -lh "$img"

if [[ -n $want_state ]]; then
    if [[ $state == - ]]; then
        echo "== $name has no saved state upstream; it must be cold-booted"
    else
        echo "== fetching state $state"
        curl -fsS --retry 5 -o "$OUT_DIR/$state" "$HOST/$state"
        ls -lh "$OUT_DIR/$state"
    fi
fi
