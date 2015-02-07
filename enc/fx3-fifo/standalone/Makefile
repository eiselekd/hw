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

