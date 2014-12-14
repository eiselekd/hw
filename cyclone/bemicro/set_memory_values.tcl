#TCL script to set memory with predefined value
proc fill_memory { serv_path base length } {
	for { set i 0x0 } { $i < $length } { set i [expr $i + 0x4] } {
	    set x [expr $base+$i]
	    master_write_32 $serv_path $x [expr (($i/4)*0x10000)+($i/4)+0x10 ]
	}
}
set base_add 0x00
set write_length [expr 32*4]
set master_service_path [lindex [get_service_paths master] 0]
open_service master $master_service_path
fill_memory $master_service_path $base_add $write_length
puts stdout "\n**********************************************"
puts stdout {Onchip RAM values out after filling with data.}
puts stdout "**********************************************"
set x [master_read_32 $master_service_path $base_add [expr $write_length/4]]
puts stdout $x

master_write_32 $master_service_path 0 0x12345678 
master_write_32 $master_service_path 4 0xabcdefed 
master_write_32 $master_service_path 8 0xba987654 

set x [master_read_32 $master_service_path 0 3]
puts stdout $x

close_service master $master_service_path



