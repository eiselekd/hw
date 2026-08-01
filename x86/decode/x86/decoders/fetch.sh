#!/usr/bin/env bash
# Fetch third-party x86 decoder tables into x86/decoders/<name>/
# Usage: ./fetch.sh [name ...]   (no args = all)
set -euo pipefail
cd "$(dirname "$0")"

clone() { # name url [sparse-path...]
  local name=$1 url=$2; shift 2
  [[ -d $name/.git ]] && { echo "== $name already present"; return; }
  echo "== cloning $name"
  git clone --filter=blob:none --depth 1 "$url" "$name"
  if (($#)); then
    git -C "$name" sparse-checkout set "$@" || true
  fi
}

get_xed()        { clone xed        https://github.com/intelxed/xed.git datafiles; }
get_nasm()       { clone nasm       https://github.com/netwide-assembler/nasm.git x86; }
get_udis86()     { clone udis86     https://github.com/vmt/udis86.git docs; }
get_zydis()      { clone zydis      https://github.com/zyantific/zydis.git Zydis/Generated Data; }
get_capstone()   { clone capstone   https://github.com/capstone-engine/capstone.git arch/X86; }
get_v86()        { clone v86        https://github.com/copy/v86.git gen src; }
get_pcjs()       { clone pcjs       https://github.com/jeffpar/pcjs.git machines/pcx86; }
get_llvm()       { clone llvm       https://github.com/llvm/llvm-project.git llvm/lib/Target/X86; }
get_x86asm-net() {
  mkdir -p x86asm-net
  [[ -f x86asm-net/x86reference.xml ]] || \
    curl -fsSL -o x86asm-net/x86reference.xml http://ref.x86asm.net/x86reference.xml
  echo "== x86asm-net ok"
}

ALL=(x86asm-net udis86 nasm xed zydis v86 pcjs capstone llvm)
for n in "${@:-${ALL[@]}}"; do "get_${n}"; done
