
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

# -----------------------------------
# connection point clock_reset
add_interface clock_reset clock end
set_interface_property clock_reset ptfSchematicName ""
add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset reset Input 1

# -----------------------------------
# connection point avalon_master
add_interface avalon_master avalon start
set_interface_property avalon_master linewrapBursts false
set_interface_property avalon_master adaptsTo ""
set_interface_property avalon_master doStreamReads false
set_interface_property avalon_master doStreamWrites false
set_interface_property avalon_master burstOnBurstBoundariesOnly false

set_interface_property avalon_master ASSOCIATED_CLOCK clock_reset

add_interface_port avalon_master master_address address Output -1
add_interface_port avalon_master master_read read Output 1
add_interface_port avalon_master master_write write Output 1
add_interface_port avalon_master master_byteenable byteenable Output -1
add_interface_port avalon_master master_readdata readdata Input -1
add_interface_port avalon_master master_readdatavalid readdatavalid Input 1
add_interface_port avalon_master master_writedata writedata Output -1
add_interface_port avalon_master master_burstcount burstcount Output -1
add_interface_port avalon_master master_waitrequest waitrequest Input 1

proc elaborate_me {}  {

  set the_data_width 32
  set the_byteenable_width 4
  set the_address_width 32
  set the_burst_count_width 8

  set_port_property control_read_base WIDTH $the_address_width
  set_port_property control_read_length WIDTH $the_address_width
  set_port_property control_write_base WIDTH $the_address_width
  set_port_property control_write_length WIDTH $the_address_width
  set_port_property user_buffer_input_data WIDTH $the_data_width
  set_port_property user_buffer_output_data WIDTH $the_data_width
  set_port_property master_address WIDTH $the_address_width
  set_port_property master_byteenable WIDTH $the_byteenable_width
  set_port_property master_readdata WIDTH $the_data_width
  set_port_property master_writedata WIDTH $the_data_width
  #set_port_property master_burstcount WIDTH $the_burst_count_width
  #set_port_property master_burstcount TERMINATION false
  
}


proc validate_me {}  {

}
