# 1. program fpga with system_top.bit
# 2. connect with XMD
# 3. run below
connect arm hw
source ps7_init.tcl
ps7_init
dow u-boot.elf
con
