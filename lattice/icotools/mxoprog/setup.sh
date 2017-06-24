#!/bin/bash
set -ex
! killall -9 mxoprog
! killall -9 icoprog
! mxoprog < SCico_impl1.svf
icoprog -f < memtest.bin
icoprog -b
icoprog -Zr2
