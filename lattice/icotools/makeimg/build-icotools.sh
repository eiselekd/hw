#!/bin/bash

set -ex

rm -rf /usr/local/src/wiringPi
git clone git://git.drogon.net/wiringPi /usr/local/src/wiringPi
cd /usr/local/src/wiringPi
./build

rm -rf /usr/local/src/icotools
git clone https://github.com/cliffordwolf/icotools.git /usr/local/src/icotools
cd /usr/local/src/icotools/icoprog
make install

