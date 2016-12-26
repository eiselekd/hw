all: vcom

vcom: vsim-libs
	vlog -work work nand_model.v
	vlog -work work +define+SHORT_RESET nand_die_model.v
	vcom -work work nandio_pkg.vhdl
	vcom -work work nandio0_top.vhd
	vcom -work work uartio.vhd
	vcom -work work br_gen.vhdl
	vcom -work work tx_unit.vhdl
	vcom -work work rx_unit.vhdl
	vcom -work work testbench.vhd

vsim-libs:
	if [ ! -d libraries/work ]; then \
	vlib libraries; \
	vlib libraries/work; \
	vmap work $(CURDIR)/libraries/work; \
	fi


sim: vcom
	vsim -novopt -t 1ps tb

