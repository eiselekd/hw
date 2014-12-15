vsim -novopt -t ps -L work -L work_lib -L rsp_xbar_demux -L cmd_xbar_mux -L cmd_xbar_demux -L rst_controller -L burst_adapter -L id_router -L addr_router -L mddr_ctrl_0_avalon_slave_translator_avalon_universal_slave_0_agent_rsp_fifo -L mddr_ctrl_0_avalon_slave_translator_avalon_universal_slave_0_agent -L mor1kx_0_avm_d_translator_avalon_universal_master_0_agent -L mddr_ctrl_0_avalon_slave_translator -L mor1kx_0_avm_d_translator -L mor1kx_0 -L mddr_ctrl_0 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver tb

source wave.do

run 210000ns

