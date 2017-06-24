#!/bin/bash

set -ex

rm -rf /usr/local/src/icestorm
mkdir -p /usr/local/src/icestorm

cd /usr/local/src/icestorm

git clone https://github.com/cliffordwolf/icestorm.git icestorm
cd icestorm
make -j3
make install

cd /usr/local/src/icestorm

git clone https://github.com/cseed/arachne-pnr.git arachne-pnr
cd arachne-pnr
make -j3
make install

cd /usr/local/src/icestorm

git clone https://github.com/cliffordwolf/yosys.git yosys
cd yosys
make -j3
make install

