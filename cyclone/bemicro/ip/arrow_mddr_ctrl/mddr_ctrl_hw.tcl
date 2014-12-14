# +-----------------------------------
# | 
# | mddr_ctrl "mobile DDR controller" v1.0
# | Harald Fluegel, Arrow Central Europe GmbH 2011.07.01.11:14:54
# | simple mobile DDR SDRAM controller for BeMicro SDK
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module mddr_ctrl
# | 
set_module_property DESCRIPTION "simple mobile DDR SDRAM controller for BeMicro SDK"
set_module_property NAME mddr_ctrl
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Harald Fluegel, Arrow Central Europe GmbH"
set_module_property DISPLAY_NAME "MDDR controller"
set_module_property TOP_LEVEL_HDL_FILE mddr_ctrl.v
set_module_property TOP_LEVEL_HDL_MODULE mddr_ctrl
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file mddr_ctrl.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter pRefreshCount INTEGER 390
set_parameter_property pRefreshCount DEFAULT_VALUE 390
set_parameter_property pRefreshCount DISPLAY_NAME pRefreshCount
set_parameter_property pRefreshCount TYPE INTEGER
set_parameter_property pRefreshCount UNITS None
set_parameter_property pRefreshCount AFFECTS_GENERATION false
set_parameter_property pRefreshCount HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
add_interface_port clock clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset reset end
set_interface_property clock_reset associatedClock clock
set_interface_property clock_reset synchronousEdges DEASSERT
set_interface_property clock_reset ENABLED true
add_interface_port clock_reset rst reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_slave
# | 
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressAlignment DYNAMIC
set_interface_property avalon_slave addressUnits WORDS
set_interface_property avalon_slave associatedClock clock
set_interface_property avalon_slave associatedReset clock_reset
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave explicitAddressSpan 0
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave isMemoryDevice true
set_interface_property avalon_slave isNonVolatileStorage false
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave printableDevice false
set_interface_property avalon_slave readLatency 0
set_interface_property avalon_slave readWaitTime 1
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0
set_interface_property avalon_slave ENABLED true
add_interface_port avalon_slave read read Input 1
add_interface_port avalon_slave readdata readdata Output 32
add_interface_port avalon_slave write write Input 1
add_interface_port avalon_slave writedata writedata Input 32
add_interface_port avalon_slave byteenable byteenable Input 4
add_interface_port avalon_slave begintransfer begintransfer Input 1
add_interface_port avalon_slave waitrequest waitrequest Output 1
add_interface_port avalon_slave address address Input 24
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point mddr
# | 
add_interface mddr conduit end
set_interface_property mddr ENABLED true
add_interface_port mddr mddr_ck export Output 1
add_interface_port mddr mddr_ck_n export Output 1
add_interface_port mddr mddr_cke export Output 1
add_interface_port mddr mddr_cs_n export Output 1
add_interface_port mddr mddr_ras_n export Output 1
add_interface_port mddr mddr_cas_n export Output 1
add_interface_port mddr mddr_we_n export Output 1
add_interface_port mddr mddr_ldm export Output 1
add_interface_port mddr mddr_udm export Output 1
add_interface_port mddr mddr_ba export Output 2
add_interface_port mddr mddr_a export Output 13
add_interface_port mddr mddr_dq_o export Output 16
add_interface_port mddr mddr_ldqs_o export Output 1
add_interface_port mddr mddr_udqs_o export Output 1
add_interface_port mddr mddr_oe export Output 1
add_interface_port mddr mddr_dq_i export Input 16
add_interface_port mddr mddr_ldqs_i export Input 1
add_interface_port mddr mddr_udqs_i export Input 1
# | 
# +-----------------------------------
