all:

vcom:
	vlog -work work upcounter.v
	vcom -work work onfi_package.vhd
	vcom -work work io_unit.vhd
	vcom -work work latch_unit.vhd
	vcom -work work nand_master.vhd
	vcom -work work testbench.vhd

vsim-libs:
	vlib libraries
	vlib libraries/work
	vmap work $(CURDIR)/libraries/work
