onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/cpu/FX3_Clk
add wave -noupdate /testbench/cpu/Clk_50
add wave -noupdate /testbench/cpu/clk_100
add wave -noupdate /testbench/cpu/clk_100_shift
add wave -noupdate /testbench/cpu/clk_100_n
add wave -noupdate /testbench/cpu/FX3_Clk
add wave -noupdate /testbench/cpu/RESET_N
add wave -noupdate /testbench/cpu/lockpll
add wave -noupdate /testbench/cpu/clklocks
add wave -noupdate /testbench/clk
add wave -noupdate -expand /testbench/cpu/clkgen0/cgo
add wave -noupdate -divider clk
add wave -noupdate /testbench/cpu/inst_clk/clkin1
add wave -noupdate /testbench/cpu/inst_clk/clkfbout
add wave -noupdate /testbench/cpu/inst_clk/clkfbout_buf
add wave -noupdate /testbench/cpu/inst_clk/clkout0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/CLKFBOUT
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/CLKOUT0
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/CLKOUT1
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/CLKOUT2
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/CLKOUT3
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/CLKOUT4
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/CLKOUT5
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/LOCKED
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/CLKFBIN
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/CLKIN
add wave -noupdate /testbench/cpu/inst_clk/pll_base_inst/RST
add wave -noupdate -divider ddr2
add wave -noupdate /testbench/cpu/oddr_inst/Q
add wave -noupdate /testbench/cpu/oddr_inst/C0
add wave -noupdate /testbench/cpu/oddr_inst/C1
add wave -noupdate /testbench/cpu/oddr_inst/CE
add wave -noupdate /testbench/cpu/oddr_inst/D0
add wave -noupdate /testbench/cpu/oddr_inst/D1
add wave -noupdate /testbench/cpu/oddr_inst/R
add wave -noupdate /testbench/cpu/oddr_inst/S
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {165669808 ps} 0}
configure wave -namecolwidth 271
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {165642997 ps} {165706159 ps}
