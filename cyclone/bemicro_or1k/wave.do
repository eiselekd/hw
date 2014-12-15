onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/CLK_50M
add wave -noupdate /tb/rst_n
add wave -noupdate -divider Instructions
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/avm_i_address_o
add wave -noupdate /tb/bemicro_top/bemicro_soc/mor1kx_0/avm_i_read_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/avm_i_readdata_i
add wave -noupdate -divider CPU0
add wave -noupdate /tb/bemicro_top/bemicro_soc/mor1kx_0/clk
add wave -noupdate /tb/bemicro_top/bemicro_soc/mor1kx_0/rst
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/mor1kx_cpu/ibus_adr_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/mor1kx_cpu/ibus_req_o
add wave -noupdate -divider soc
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/clk_clk
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/reset_reset_n
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_ck
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_ck_n
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_cke
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_cs_n
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_ras_n
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_cas_n
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_we_n
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_ldm
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_udm
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_ba
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_a
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_dq_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_ldqs_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_udqs_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_oe
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_dq_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_ldqs_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mddr_ctrl_0_mddr_udqs_i
add wave -noupdate -divider ibus
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/clk
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/rst
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/cpu_err_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/cpu_ack_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/cpu_dat_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/cpu_adr_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/cpu_dat_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/cpu_req_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/cpu_bsel_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/cpu_we_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/cpu_burst_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/avm_address_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/avm_byteenable_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/avm_read_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/avm_readdata_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/avm_burstcount_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/avm_write_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/avm_writedata_o
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/avm_waitrequest_i
add wave -noupdate -radix hexadecimal /tb/bemicro_top/bemicro_soc/mor1kx_0/mor1kx_cpu0/genblk1/ibus_bridge/avm_readdatavalid_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {243418 ps} 0}
configure wave -namecolwidth 289
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
WaveRestoreZoom {0 ps} {847839 ps}
