
module bemicro_top
    (
    output wire RAM_A0,
    output wire RAM_A1,
    output wire RAM_A2,
    output wire RAM_A3,
    output wire RAM_A4,
    output wire RAM_A5,
    output wire RAM_A6,
    output wire RAM_A7,
    output wire RAM_A8,
    output wire RAM_A9,
    output wire RAM_A10,
    output wire RAM_A11,
    output wire RAM_A12,
    output wire RAM_A13,
    output wire RAM_BA0,
    output wire RAM_BA1,
     
    output wire RAM_CK_N,
    output wire RAM_CK_P,
    output wire RAM_CKE,
    output wire RAM_CS_N,
    output wire RAM_WS_N,
    output wire RAM_RAS_N,
    output wire RAM_CAS_N,
     
    inout wire 	RAM_D0,
    inout wire 	RAM_D1,
    inout wire 	RAM_D2,
    inout wire 	RAM_D3,
    inout wire 	RAM_D4,
    inout wire 	RAM_D5,
    inout wire 	RAM_D6,
    inout wire 	RAM_D7,
    inout wire 	RAM_D8,
    inout wire 	RAM_D9,
    inout wire 	RAM_D10,
    inout wire 	RAM_D11,
    inout wire 	RAM_D12,
    inout wire 	RAM_D13,
    inout wire 	RAM_D14,
    inout wire 	RAM_D15,
    
    output wire RAM_LDM,
    output wire RAM_UDM,
    inout wire 	RAM_LDQS,
    inout wire 	RAM_UDQS,
     
    input wire 	CLK_FPGA_50M 
    );

//----------------------------------------------------------------------------
// local variables for MDDR RAM
//----------------------------------------------------------------------------

wire    [12:0]  ram_addr;
wire    [1:0]   ram_baddr;
wire    [15:0]  ram_dq_i;
wire    [15:0]  ram_dq_o;
wire            ram_ldqs_i;
wire            ram_ldqs_o;
wire            ram_udqs_i;
wire            ram_udqs_o;
wire            ram_oe;

//------------------------------------------------------------------------------
// SOPC
//------------------------------------------------------------------------------

bemicro bemicro_soc
    (
    .clk_clk(CLK_FPGA_50M),
    .mddr_ctrl_0_mddr_a(ram_addr),
    .mddr_ctrl_0_mddr_ba(ram_baddr),
    .mddr_ctrl_0_mddr_ck(RAM_CK_P),
    .mddr_ctrl_0_mddr_ck_n(RAM_CK_N),
    .mddr_ctrl_0_mddr_cke(RAM_CKE),
    .mddr_ctrl_0_mddr_cs_n(RAM_CS_N),
    .mddr_ctrl_0_mddr_ras_n(RAM_RAS_N),
    .mddr_ctrl_0_mddr_cas_n(RAM_CAS_N),
    .mddr_ctrl_0_mddr_we_n(RAM_WS_N),
    .mddr_ctrl_0_mddr_ldm(RAM_LDM),
    .mddr_ctrl_0_mddr_udm(RAM_UDM),
    .mddr_ctrl_0_mddr_dq_i(ram_dq_i),
    .mddr_ctrl_0_mddr_dq_o(ram_dq_o),
    .mddr_ctrl_0_mddr_ldqs_i(ram_ldqs_i),
    .mddr_ctrl_0_mddr_ldqs_o(ram_ldqs_o),
    .mddr_ctrl_0_mddr_udqs_i(ram_udqs_i),
    .mddr_ctrl_0_mddr_udqs_o(ram_udqs_o),
    .mddr_ctrl_0_mddr_oe(ram_oe)
    );

//----------------------------------------------------------------------------
// outputs
//----------------------------------------------------------------------------

assign RAM_A0   = ram_addr[ 0];
assign RAM_A1   = ram_addr[ 1];
assign RAM_A2   = ram_addr[ 2];
assign RAM_A3   = ram_addr[ 3];
assign RAM_A4   = ram_addr[ 4];
assign RAM_A5   = ram_addr[ 5];
assign RAM_A6   = ram_addr[ 6];
assign RAM_A7   = ram_addr[ 7];
assign RAM_A8   = ram_addr[ 8];
assign RAM_A9   = ram_addr[ 9];
assign RAM_A10  = ram_addr[10];
assign RAM_A11  = ram_addr[11];
assign RAM_A12  = ram_addr[12];
assign RAM_A13  = 1'b0;

assign RAM_BA0  = ram_baddr[0];
assign RAM_BA1  = ram_baddr[1];

assign RAM_D0   = ram_oe ? ram_dq_o[ 0] : 1'bz;
assign RAM_D1   = ram_oe ? ram_dq_o[ 1] : 1'bz;
assign RAM_D2   = ram_oe ? ram_dq_o[ 2] : 1'bz;
assign RAM_D3   = ram_oe ? ram_dq_o[ 3] : 1'bz;
assign RAM_D4   = ram_oe ? ram_dq_o[ 4] : 1'bz;
assign RAM_D5   = ram_oe ? ram_dq_o[ 5] : 1'bz;
assign RAM_D6   = ram_oe ? ram_dq_o[ 6] : 1'bz;
assign RAM_D7   = ram_oe ? ram_dq_o[ 7] : 1'bz;
assign RAM_D8   = ram_oe ? ram_dq_o[ 8] : 1'bz;
assign RAM_D9   = ram_oe ? ram_dq_o[ 9] : 1'bz;
assign RAM_D10  = ram_oe ? ram_dq_o[10] : 1'bz;
assign RAM_D11  = ram_oe ? ram_dq_o[11] : 1'bz;
assign RAM_D12  = ram_oe ? ram_dq_o[12] : 1'bz;
assign RAM_D13  = ram_oe ? ram_dq_o[13] : 1'bz;
assign RAM_D14  = ram_oe ? ram_dq_o[14] : 1'bz;
assign RAM_D15  = ram_oe ? ram_dq_o[15] : 1'bz;

assign ram_dq_i = {RAM_D15, RAM_D14, RAM_D13, RAM_D12, RAM_D11, RAM_D10, RAM_D9, RAM_D8,
                   RAM_D7,  RAM_D6,  RAM_D5,  RAM_D4,  RAM_D3,  RAM_D2,  RAM_D1, RAM_D0};

assign RAM_LDQS = ram_oe ? ram_ldqs_o : 1'bz;
assign RAM_UDQS = ram_oe ? ram_udqs_o : 1'bz;

assign ram_ldqs_i = RAM_LDQS;
assign ram_udqs_i = RAM_UDQS;

//------------------------------------------------------------------------------

endmodule
