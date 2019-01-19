
all:
	verilator --trace --cc out.v --exe state_main.cpp
	make -j -C obj_dir -f Vout.mk Vout
	obj_dir/Vout

wave:
	gtkwave dpi.vcd
