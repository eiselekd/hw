onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/Clk_w
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/Clk_r
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/RESET_N
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/fifo_read
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/fifo_dataout
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/fifo_haspacket
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/fifo_empty
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/fifo_write
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/fifo_datain
add wave -noupdate -radix decimal /fx3fifo_tb/tohost/fifo_isfull
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {156769403 ps} 0}
configure wave -namecolwidth 150
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
WaveRestoreZoom {155732 ns} {156756 ns}
