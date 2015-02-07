all:
	@echo make syn : run synthesis
	@echo make sim : run simulation
	@echo make op  : open proj

syn:
	vivado -mode tcl -source standalone.tcl

sim:
	vivado -mode tcl -source standalone_sim.tcl

op:
	vivado -mode tcl -source standalone_simple.tcl


test:
	vcom -quiet -explicit -93  -work work standalone.srcs/sources_1/imports/hdl/fx3_pkg.vhd
	vcom -quiet -explicit -93  -work work standalone.srcs/sources_1/imports/hdl/fx3bridge_v1_0.vhd
	vcom -quiet -explicit -93  -work work standalone.srcs/sources_1/imports/hdl/fx3bridge_v1_0_tb.vhd
