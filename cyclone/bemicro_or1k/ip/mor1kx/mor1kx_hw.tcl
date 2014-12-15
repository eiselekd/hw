
# -----------------------------------
set_module_property DESCRIPTION "mor1kx cpu"
set_module_property NAME mor1kx
set_module_property VERSION 1.0
set_module_property GROUP "Processor"
set_module_property AUTHOR openrisc
set_module_property DISPLAY_NAME openrisc-mor1kx
set_module_property TOP_LEVEL_HDL_FILE mor1kx_master.v
set_module_property TOP_LEVEL_HDL_MODULE mor1kx_master
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VERILOG false
set_module_property SIMULATION_MODEL_IN_VHDL false
set_module_property SIMULATION_MODEL_HAS_TULIPS false
set_module_property SIMULATION_MODEL_IS_OBFUSCATED false

set_module_property ELABORATION_CALLBACK    elaborate_me
set_module_property VALIDATION_CALLBACK     validate_me

# -----------------------------------
add_file rtl/verilog/mor1kx_branch_prediction.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_ctrl_espresso.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_fetch_espresso.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_simple_dpram_sclk.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_bus_if_avalon.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_ctrl_prontoespresso.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_fetch_prontoespresso.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx-sprs.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_bus_if_wb32.v  {SYNTHESIS SIMULATION} 
add_file rtl/verilog/mor1kx_dcache.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_fetch_tcm_prontoespresso.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_store_buffer.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_cache_lru.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_decode_execute_cappuccino.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_icache.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_ticktimer.v  {SYNTHESIS SIMULATION} 
add_file rtl/verilog/mor1kx_cfgrs.v {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_decode.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_immu.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_true_dpram_sclk.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_cpu_cappuccino.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx-defines.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_lsu_cappuccino.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_utils.vh  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_cpu_espresso.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_dmmu.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_lsu_espresso.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_cpu_prontoespresso.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_execute_alu.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_pic.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_wb_mux_cappuccino.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_cpu.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_execute_ctrl_cappuccino.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_rf_cappuccino.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_wb_mux_espresso.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_ctrl_cappuccino.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_fetch_cappuccino.v  {SYNTHESIS SIMULATION}
add_file rtl/verilog/mor1kx_rf_espresso.v  {SYNTHESIS SIMULATION}
add_file mor1kx_master.v  {SYNTHESIS SIMULATION}

# -----------------------------------
# connection point clock_reset
add_interface clock_reset clock end
set_interface_property clock_reset ptfSchematicName ""
add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset rst reset Input 1

# -----------------------------------
# connection point avm_d
add_interface avm_d avalon start
set_interface_property avm_d linewrapBursts false
set_interface_property avm_d adaptsTo ""
set_interface_property avm_d doStreamReads false
set_interface_property avm_d doStreamWrites false
set_interface_property avm_d burstOnBurstBoundariesOnly false

set_interface_property avm_d ASSOCIATED_CLOCK clock_reset

add_interface_port avm_d avm_d_address_o address Output 32
add_interface_port avm_d avm_d_byteenable_o byteenable Output 4
add_interface_port avm_d avm_d_read_o read Output 1
add_interface_port avm_d avm_d_readdata_i readdata Input 32
add_interface_port avm_d avm_d_burstcount_o burstcount Output 4
add_interface_port avm_d avm_d_write_o write Output 1
add_interface_port avm_d avm_d_writedata_o writedata Output 32
add_interface_port avm_d avm_d_waitrequest_i waitrequest Input 1
add_interface_port avm_d avm_d_readdatavalid_i readdatavalid Input 1

# -----------------------------------
# connection point avm_i
add_interface avm_i avalon start
set_interface_property avm_i linewrapBursts false
set_interface_property avm_i adaptsTo ""
set_interface_property avm_i doStreamReads false
set_interface_property avm_i doStreamWrites false
set_interface_property avm_i burstOnBurstBoundariesOnly false

set_interface_property avm_i ASSOCIATED_CLOCK clock_reset

add_interface_port avm_i avm_i_address_o address Output 32
add_interface_port avm_i avm_i_byteenable_o byteenable Output 4
add_interface_port avm_i avm_i_read_o read Output 1
add_interface_port avm_i avm_i_readdata_i readdata Input 32
add_interface_port avm_i avm_i_burstcount_o burstcount Output 4
add_interface_port avm_i avm_i_waitrequest_i waitrequest Input 1
add_interface_port avm_i avm_i_readdatavalid_i readdatavalid Input 1

proc elaborate_me {}  {

}

proc validate_me {}  {

}
