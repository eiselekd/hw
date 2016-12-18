onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider clk
add wave -noupdate /testbench/d3/fx3clk/c0
add wave -noupdate /testbench/d3/fx3clk/c1
add wave -noupdate /testbench/d3/clkgen0/clk
add wave -noupdate /testbench/d3/clk_fpga_50m
add wave -noupdate -radix hexadecimal /testbench/d3/fx3clk/areset
add wave -noupdate -radix hexadecimal /testbench/d3/fx3clk/inclk0
add wave -noupdate -radix hexadecimal /testbench/d3/fx3clk/c0
add wave -noupdate -radix hexadecimal /testbench/d3/fx3clk/c1
add wave -noupdate -radix hexadecimal /testbench/d3/fx3clk/locked
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/d3/fx3clk/sub_wire0
add wave -noupdate /testbench/d3/fx3clk/sub_wire1
add wave -noupdate /testbench/d3/fx3clk/sub_wire2
add wave -noupdate /testbench/d3/fx3clk/sub_wire3
add wave -noupdate /testbench/d3/fx3clk/sub_wire4
add wave -noupdate /testbench/d3/fx3clk/sub_wire5
add wave -noupdate /testbench/d3/fx3clk/sub_wire6_bv
add wave -noupdate /testbench/d3/fx3clk/sub_wire6
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {365608300 ps} 0}
configure wave -namecolwidth 273
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
WaveRestoreZoom {365521588 ps} {365883074 ps}
