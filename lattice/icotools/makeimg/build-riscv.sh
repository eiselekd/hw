#!/bin/bash

set -ex

rm -rf /usr/local/src/picorv32
git clone https://github.com/cliffordwolf/picorv32.git /usr/local/src/picorv32
cd /usr/local/src/picorv32

make download-tools

rm -rf /opt/riscv32{i,ic,im,imc}
mkdir -p /opt/riscv32{i,ic,im,imc}

make -j2 build-riscv32i-tools-bh
make clean

make -j2 build-riscv32ic-tools-bh
make clean

make -j2 build-riscv32im-tools-bh
make clean

make -j2 build-riscv32imc-tools-bh
make clean

