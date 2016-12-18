onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider APB
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/r.idx
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/r.pidx
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/r.enable
add wave -noupdate -divider {APB Signals}
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/rst
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/apbi
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/apbo
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/Clk_sys
add wave -noupdate /testbench/cpu/RESET_N
add wave -noupdate /testbench/cpu/FX3_Clk
add wave -noupdate /testbench/cpu/FX3_SlRd_N
add wave -noupdate /testbench/cpu/FX3_SlWr_N
add wave -noupdate /testbench/cpu/FX3_SlOe_N
add wave -noupdate /testbench/cpu/FX3_Pktend_N
add wave -noupdate /testbench/cpu/FX3_A1
add wave -noupdate -radix decimal /testbench/cpu/FX3_DQ
add wave -noupdate /testbench/cpu/FX3_FlagA
add wave -noupdate /testbench/cpu/FX3_FlagB
add wave -noupdate /testbench/cpu/Eth_Rst_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/Clk_fx3
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/Clk_fx3_shift
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/FX3_SlRd_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/FX3_SlWr_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/FX3_SlOe_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/FX3_Pktend_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/FX3_A1
add wave -noupdate /testbench/cpu/Clk_50
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/Clk_sys
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/RESET_N
add wave -noupdate -radix decimal /testbench/cpu/fx3/fxb/avl_data
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/avl_ready
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/avl_valid
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/avl_endofpacket
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/avl_startofpacket
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_SlRd_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_SlWr_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_SlOe_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_SlTri_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_Pktend_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_A1
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_DQ_o
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_DQ_i
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_FlagA
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/FX3_FlagB
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/rsys
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/rsysin
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/rfx3.state
add wave -noupdate -radix hexadecimal -childformat {{/testbench/cpu/fx3/fxb/rfx3.state -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.rcnt -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.cnt -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.delay -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.FX3_SlRd_N -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.FX3_SlWr_N -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.FX3_SlOe_N -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.FX3_SlTri_N -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.FX3_Pktend_N -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.FX3_A1 -radix hexadecimal} {/testbench/cpu/fx3/fxb/rfx3.FX3_DQ_o -radix decimal} {/testbench/cpu/fx3/fxb/rfx3.tohost_fifo_read -radix hexadecimal}} -expand -subitemconfig {/testbench/cpu/fx3/fxb/rfx3.state {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.rcnt {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.cnt {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.delay {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.FX3_SlRd_N {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.FX3_SlWr_N {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.FX3_SlOe_N {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.FX3_SlTri_N {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.FX3_Pktend_N {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.FX3_A1 {-radix hexadecimal} /testbench/cpu/fx3/fxb/rfx3.FX3_DQ_o {-radix decimal} /testbench/cpu/fx3/fxb/rfx3.tohost_fifo_read {-radix hexadecimal}} /testbench/cpu/fx3/fxb/rfx3
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/Clk_fx3
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/rfx3in
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/rst
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tofpga_fifo_freeforpacket
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost_fifo_read
add wave -noupdate -radix decimal /testbench/cpu/fx3/fxb/tohost_fifo_dataout
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost_fifo_haspacket
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost_fifo_empty
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost_fifo_write
add wave -noupdate -radix decimal /testbench/cpu/fx3/fxb/tohost_fifo_datain
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost_fifo_isfull
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/gpif_fragmentsize
add wave -noupdate -divider fifo
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/Clk_w
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/Clk_r
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/RESET_N
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/fifo_read
add wave -noupdate -radix decimal /testbench/cpu/fx3/fxb/tohost/fifo_dataout
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/fifo_haspacket
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/fifo_empty
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/fifo_write
add wave -noupdate -radix decimal /testbench/cpu/fx3/fxb/tohost/fifo_datain
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/fifo_isfull
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/rw
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/rwin
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/rr
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/rrin
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/rst
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/fifo_renable_sig
add wave -noupdate -radix hexadecimal /testbench/cpu/fx3/fxb/tohost/fifo_raddress
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {336031416 ps} 0}
configure wave -namecolwidth 234
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
WaveRestoreZoom {335999160 ps} {336102840 ps}
