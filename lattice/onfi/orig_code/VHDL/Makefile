all: vcom

vcom: vsim-libs
	vlog -work work upcounter.v
	vlog -work work nand_model.v
	vlog -work work +define+SHORT_RESET nand_die_model.v
	vcom -work work onfi_package.vhd
	vcom -work work io_unit.vhd
	vcom -work work latch_unit.vhd
	vcom -work work nand_master.vhd
	vcom -work work testbench.vhd


vsim-libs:
	if [ ! -d libraries/work ]; then \
	vlib libraries; \
	vlib libraries/work; \
	vmap work $(CURDIR)/libraries/work; \
	fi


sim: vcom
	vsim -novopt -t 1ps tb

