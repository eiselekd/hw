#!/bin/bash
killall -9 icoprog
icoprog -f < memtest.bin
icoprog -b
icoprog -Zr2
