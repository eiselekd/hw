// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.4 (win64) Build 1071353 Tue Nov 18 18:24:04 MST 2014
// Date        : Sun Jan 11 22:16:39 2015
// Host        : sol-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode funcsim c:/Users/sol/git/hw/enc/fx3-fifo/fx3bridge_0/fx3bridge_0_funcsim.v
// Design      : fx3bridge_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fx3bridge_v1_0,Vivado 2014.4" *) (* CHECK_LICENSE_TYPE = "fx3bridge_0,fx3bridge_v1_0,{}" *) 
(* core_generation_info = "fx3bridge_0,fx3bridge_v1_0,{x_ipProduct=Vivado 2014.4,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=fx3bridge,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,C_M00_AXIS_TDATA_WIDTH=32,C_M00_AXIS_START_COUNT=32,C_S00_AXIS_TDATA_WIDTH=32}" *) 
(* NotValidForBitStream *)
module fx3bridge_0
   (FX3_Clk,
    FX3_SLCS_N,
    FX3_SlRd_N,
    FX3_SlWr_N,
    FX3_SlOe_N,
    FX3_Pktend_N,
    FX3_A,
    FX3_SlTri,
    FX3_DQ_o,
    FX3_DQ_i,
    FX3_FlagA,
    FX3_FlagB,
    m00_axis_tdata,
    m00_axis_tstrb,
    m00_axis_tlast,
    m00_axis_tvalid,
    m00_axis_tready,
    m00_axis_aclk,
    m00_axis_aresetn,
    s00_axis_tdata,
    s00_axis_tstrb,
    s00_axis_tlast,
    s00_axis_tvalid,
    s00_axis_tready,
    s00_axis_aclk,
    s00_axis_aresetn);
  (* x_interface_info = "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_Clk" *) output FX3_Clk;
  (* x_interface_info = "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SLCS_N" *) output FX3_SLCS_N;
  (* x_interface_info = "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SlRd_N" *) output FX3_SlRd_N;
  (* x_interface_info = "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SlWr_N" *) output FX3_SlWr_N;
  (* x_interface_info = "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SlOe_N" *) output FX3_SlOe_N;
  (* x_interface_info = "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_Pktend_N" *) output FX3_Pktend_N;
  output [1:0]FX3_A;
  (* x_interface_info = "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SlTri" *) output FX3_SlTri;
  output [15:0]FX3_DQ_o;
  input [15:0]FX3_DQ_i;
  (* x_interface_info = "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_FlagA" *) input FX3_FlagA;
  (* x_interface_info = "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_FlagB" *) input FX3_FlagB;
  output [31:0]m00_axis_tdata;
  output [3:0]m00_axis_tstrb;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M00_AXIS TLAST" *) output m00_axis_tlast;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M00_AXIS TVALID" *) output m00_axis_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M00_AXIS TREADY" *) input m00_axis_tready;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 M00_AXIS_CLK CLK" *) input m00_axis_aclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 M00_AXIS_RST RST" *) input m00_axis_aresetn;
  input [31:0]s00_axis_tdata;
  input [3:0]s00_axis_tstrb;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S00_AXIS TLAST" *) input s00_axis_tlast;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S00_AXIS TVALID" *) input s00_axis_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S00_AXIS TREADY" *) output s00_axis_tready;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 S00_AXIS_CLK CLK" *) input s00_axis_aclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 S00_AXIS_RST RST" *) input s00_axis_aresetn;

  wire \<const0> ;
  wire \<const1> ;
  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [2:0]\^m00_axis_tdata ;
  wire m00_axis_tready;
  wire m00_axis_tvalid;
  wire s00_axis_aclk;
  wire s00_axis_aresetn;
  wire s00_axis_tlast;
  wire s00_axis_tready;
  wire s00_axis_tvalid;

  assign m00_axis_tdata[31] = \<const0> ;
  assign m00_axis_tdata[30] = \<const0> ;
  assign m00_axis_tdata[29] = \<const0> ;
  assign m00_axis_tdata[28] = \<const0> ;
  assign m00_axis_tdata[27] = \<const0> ;
  assign m00_axis_tdata[26] = \<const0> ;
  assign m00_axis_tdata[25] = \<const0> ;
  assign m00_axis_tdata[24] = \<const0> ;
  assign m00_axis_tdata[23] = \<const0> ;
  assign m00_axis_tdata[22] = \<const0> ;
  assign m00_axis_tdata[21] = \<const0> ;
  assign m00_axis_tdata[20] = \<const0> ;
  assign m00_axis_tdata[19] = \<const0> ;
  assign m00_axis_tdata[18] = \<const0> ;
  assign m00_axis_tdata[17] = \<const0> ;
  assign m00_axis_tdata[16] = \<const0> ;
  assign m00_axis_tdata[15] = \<const0> ;
  assign m00_axis_tdata[14] = \<const0> ;
  assign m00_axis_tdata[13] = \<const0> ;
  assign m00_axis_tdata[12] = \<const0> ;
  assign m00_axis_tdata[11] = \<const0> ;
  assign m00_axis_tdata[10] = \<const0> ;
  assign m00_axis_tdata[9] = \<const0> ;
  assign m00_axis_tdata[8] = \<const0> ;
  assign m00_axis_tdata[7] = \<const0> ;
  assign m00_axis_tdata[6] = \<const0> ;
  assign m00_axis_tdata[5] = \<const0> ;
  assign m00_axis_tdata[4] = \<const0> ;
  assign m00_axis_tdata[3] = \<const0> ;
  assign m00_axis_tdata[2:0] = \^m00_axis_tdata [2:0];
  assign m00_axis_tlast = \<const0> ;
  assign m00_axis_tstrb[3] = \<const1> ;
  assign m00_axis_tstrb[2] = \<const1> ;
  assign m00_axis_tstrb[1] = \<const1> ;
  assign m00_axis_tstrb[0] = \<const1> ;
GND GND
       (.G(\<const0> ));
fx3bridge_0_fx3bridge_v1_0__parameterized0 U0
       (.m00_axis_aclk(m00_axis_aclk),
        .m00_axis_aresetn(m00_axis_aresetn),
        .m00_axis_tdata(\^m00_axis_tdata ),
        .m00_axis_tready(m00_axis_tready),
        .m00_axis_tvalid(m00_axis_tvalid),
        .s00_axis_aclk(s00_axis_aclk),
        .s00_axis_aresetn(s00_axis_aresetn),
        .s00_axis_tlast(s00_axis_tlast),
        .s00_axis_tready(s00_axis_tready),
        .s00_axis_tvalid(s00_axis_tvalid));
VCC VCC
       (.P(\<const1> ));
endmodule

(* ORIG_REF_NAME = "fx3bridge_v1_0_M00_AXIS" *) 
module fx3bridge_0_fx3bridge_v1_0_M00_AXIS__parameterized0
   (m00_axis_tdata,
    m00_axis_tvalid,
    m00_axis_aclk,
    m00_axis_aresetn,
    m00_axis_tready);
  output [2:0]m00_axis_tdata;
  output m00_axis_tvalid;
  input m00_axis_aclk;
  input m00_axis_aresetn;
  input m00_axis_tready;

  wire clear;
  wire [4:0]count_reg__0;
  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [2:0]m00_axis_tdata;
  wire m00_axis_tready;
  wire m00_axis_tvalid;
  wire [1:0]mst_exec_state;
  wire n_0_axis_tvalid_delay_i_1;
  wire \n_0_count[2]_i_1 ;
  wire \n_0_count[4]_i_1 ;
  wire \n_0_mst_exec_state[0]_i_1 ;
  wire \n_0_mst_exec_state[1]_i_1 ;
  wire \n_0_mst_exec_state[1]_i_2 ;
  wire \n_0_stream_data_out[0]_i_1 ;
  wire \n_0_stream_data_out[1]_i_1 ;
  wire \n_0_stream_data_out[2]_i_3 ;
  wire [4:0]plusOp;
  wire [0:0]read_pointer;
  wire tx_en;

LUT3 #(
    .INIT(8'h40)) 
     axis_tvalid_delay_i_1
       (.I0(mst_exec_state[0]),
        .I1(mst_exec_state[1]),
        .I2(m00_axis_aresetn),
        .O(n_0_axis_tvalid_delay_i_1));
FDRE axis_tvalid_delay_reg
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(n_0_axis_tvalid_delay_i_1),
        .Q(m00_axis_tvalid),
        .R(1'b0));
(* SOFT_HLUTNM = "soft_lutpair4" *) 
   LUT1 #(
    .INIT(2'h1)) 
     \count[0]_i_1 
       (.I0(count_reg__0[0]),
        .O(plusOp[0]));
(* SOFT_HLUTNM = "soft_lutpair4" *) 
   LUT2 #(
    .INIT(4'h6)) 
     \count[1]_i_1 
       (.I0(count_reg__0[0]),
        .I1(count_reg__0[1]),
        .O(plusOp[1]));
(* SOFT_HLUTNM = "soft_lutpair2" *) 
   LUT3 #(
    .INIT(8'h78)) 
     \count[2]_i_1 
       (.I0(count_reg__0[0]),
        .I1(count_reg__0[1]),
        .I2(count_reg__0[2]),
        .O(\n_0_count[2]_i_1 ));
(* SOFT_HLUTNM = "soft_lutpair2" *) 
   LUT4 #(
    .INIT(16'h7F80)) 
     \count[3]_i_1 
       (.I0(count_reg__0[1]),
        .I1(count_reg__0[0]),
        .I2(count_reg__0[2]),
        .I3(count_reg__0[3]),
        .O(plusOp[3]));
LUT3 #(
    .INIT(8'h40)) 
     \count[4]_i_1 
       (.I0(mst_exec_state[1]),
        .I1(mst_exec_state[0]),
        .I2(\n_0_mst_exec_state[1]_i_2 ),
        .O(\n_0_count[4]_i_1 ));
(* SOFT_HLUTNM = "soft_lutpair0" *) 
   LUT5 #(
    .INIT(32'h7FFF8000)) 
     \count[4]_i_2 
       (.I0(count_reg__0[2]),
        .I1(count_reg__0[0]),
        .I2(count_reg__0[1]),
        .I3(count_reg__0[3]),
        .I4(count_reg__0[4]),
        .O(plusOp[4]));
FDRE \count_reg[0] 
       (.C(m00_axis_aclk),
        .CE(\n_0_count[4]_i_1 ),
        .D(plusOp[0]),
        .Q(count_reg__0[0]),
        .R(clear));
FDRE \count_reg[1] 
       (.C(m00_axis_aclk),
        .CE(\n_0_count[4]_i_1 ),
        .D(plusOp[1]),
        .Q(count_reg__0[1]),
        .R(clear));
FDRE \count_reg[2] 
       (.C(m00_axis_aclk),
        .CE(\n_0_count[4]_i_1 ),
        .D(\n_0_count[2]_i_1 ),
        .Q(count_reg__0[2]),
        .R(clear));
FDRE \count_reg[3] 
       (.C(m00_axis_aclk),
        .CE(\n_0_count[4]_i_1 ),
        .D(plusOp[3]),
        .Q(count_reg__0[3]),
        .R(clear));
FDRE \count_reg[4] 
       (.C(m00_axis_aclk),
        .CE(\n_0_count[4]_i_1 ),
        .D(plusOp[4]),
        .Q(count_reg__0[4]),
        .R(clear));
(* SOFT_HLUTNM = "soft_lutpair1" *) 
   LUT4 #(
    .INIT(16'h0D00)) 
     \mst_exec_state[0]_i_1 
       (.I0(mst_exec_state[0]),
        .I1(\n_0_mst_exec_state[1]_i_2 ),
        .I2(mst_exec_state[1]),
        .I3(m00_axis_aresetn),
        .O(\n_0_mst_exec_state[0]_i_1 ));
(* SOFT_HLUTNM = "soft_lutpair1" *) 
   LUT4 #(
    .INIT(16'h2600)) 
     \mst_exec_state[1]_i_1 
       (.I0(mst_exec_state[1]),
        .I1(mst_exec_state[0]),
        .I2(\n_0_mst_exec_state[1]_i_2 ),
        .I3(m00_axis_aresetn),
        .O(\n_0_mst_exec_state[1]_i_1 ));
(* SOFT_HLUTNM = "soft_lutpair0" *) 
   LUT5 #(
    .INIT(32'h7FFFFFFF)) 
     \mst_exec_state[1]_i_2 
       (.I0(count_reg__0[4]),
        .I1(count_reg__0[1]),
        .I2(count_reg__0[0]),
        .I3(count_reg__0[2]),
        .I4(count_reg__0[3]),
        .O(\n_0_mst_exec_state[1]_i_2 ));
FDRE \mst_exec_state_reg[0] 
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(\n_0_mst_exec_state[0]_i_1 ),
        .Q(mst_exec_state[0]),
        .R(1'b0));
FDRE \mst_exec_state_reg[1] 
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(\n_0_mst_exec_state[1]_i_1 ),
        .Q(mst_exec_state[1]),
        .R(1'b0));
FDRE \read_pointer_reg[0] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(\n_0_stream_data_out[0]_i_1 ),
        .Q(read_pointer),
        .R(clear));
LUT1 #(
    .INIT(2'h1)) 
     \stream_data_out[0]_i_1 
       (.I0(read_pointer),
        .O(\n_0_stream_data_out[0]_i_1 ));
(* SOFT_HLUTNM = "soft_lutpair3" *) 
   LUT2 #(
    .INIT(4'h6)) 
     \stream_data_out[1]_i_1 
       (.I0(read_pointer),
        .I1(m00_axis_tdata[1]),
        .O(\n_0_stream_data_out[1]_i_1 ));
LUT1 #(
    .INIT(2'h1)) 
     \stream_data_out[2]_i_1 
       (.I0(m00_axis_aresetn),
        .O(clear));
LUT3 #(
    .INIT(8'h08)) 
     \stream_data_out[2]_i_2 
       (.I0(m00_axis_tready),
        .I1(mst_exec_state[1]),
        .I2(mst_exec_state[0]),
        .O(tx_en));
(* SOFT_HLUTNM = "soft_lutpair3" *) 
   LUT2 #(
    .INIT(4'h8)) 
     \stream_data_out[2]_i_3 
       (.I0(m00_axis_tdata[1]),
        .I1(read_pointer),
        .O(\n_0_stream_data_out[2]_i_3 ));
FDSE \stream_data_out_reg[0] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(\n_0_stream_data_out[0]_i_1 ),
        .Q(m00_axis_tdata[0]),
        .S(clear));
FDRE \stream_data_out_reg[1] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(\n_0_stream_data_out[1]_i_1 ),
        .Q(m00_axis_tdata[1]),
        .R(clear));
FDRE \stream_data_out_reg[2] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(\n_0_stream_data_out[2]_i_3 ),
        .Q(m00_axis_tdata[2]),
        .R(clear));
endmodule

(* ORIG_REF_NAME = "fx3bridge_v1_0_S00_AXIS" *) 
module fx3bridge_0_fx3bridge_v1_0_S00_AXIS__parameterized0
   (s00_axis_tready,
    s00_axis_aclk,
    s00_axis_aresetn,
    s00_axis_tvalid,
    s00_axis_tlast);
  output s00_axis_tready;
  input s00_axis_aclk;
  input s00_axis_aresetn;
  input s00_axis_tvalid;
  input s00_axis_tlast;

  wire n_0_mst_exec_state_i_1;
  wire n_0_writes_done_i_1;
  wire s00_axis_aclk;
  wire s00_axis_aresetn;
  wire s00_axis_tlast;
  wire s00_axis_tready;
  wire s00_axis_tvalid;
  wire writes_done;

(* SOFT_HLUTNM = "soft_lutpair5" *) 
   LUT4 #(
    .INIT(16'h08A8)) 
     mst_exec_state_i_1
       (.I0(s00_axis_aresetn),
        .I1(s00_axis_tvalid),
        .I2(s00_axis_tready),
        .I3(writes_done),
        .O(n_0_mst_exec_state_i_1));
FDRE mst_exec_state_reg
       (.C(s00_axis_aclk),
        .CE(1'b1),
        .D(n_0_mst_exec_state_i_1),
        .Q(s00_axis_tready),
        .R(1'b0));
(* SOFT_HLUTNM = "soft_lutpair5" *) 
   LUT5 #(
    .INIT(32'hAA2AAA00)) 
     writes_done_i_1
       (.I0(s00_axis_aresetn),
        .I1(s00_axis_tvalid),
        .I2(s00_axis_tready),
        .I3(s00_axis_tlast),
        .I4(writes_done),
        .O(n_0_writes_done_i_1));
FDRE writes_done_reg
       (.C(s00_axis_aclk),
        .CE(1'b1),
        .D(n_0_writes_done_i_1),
        .Q(writes_done),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "fx3bridge_v1_0" *) 
module fx3bridge_0_fx3bridge_v1_0__parameterized0
   (s00_axis_tready,
    m00_axis_tdata,
    m00_axis_tvalid,
    s00_axis_aresetn,
    s00_axis_tvalid,
    m00_axis_aresetn,
    m00_axis_aclk,
    m00_axis_tready,
    s00_axis_tlast,
    s00_axis_aclk);
  output s00_axis_tready;
  output [2:0]m00_axis_tdata;
  output m00_axis_tvalid;
  input s00_axis_aresetn;
  input s00_axis_tvalid;
  input m00_axis_aresetn;
  input m00_axis_aclk;
  input m00_axis_tready;
  input s00_axis_tlast;
  input s00_axis_aclk;

  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [2:0]m00_axis_tdata;
  wire m00_axis_tready;
  wire m00_axis_tvalid;
  wire s00_axis_aclk;
  wire s00_axis_aresetn;
  wire s00_axis_tlast;
  wire s00_axis_tready;
  wire s00_axis_tvalid;

fx3bridge_0_fx3bridge_v1_0_M00_AXIS__parameterized0 fx3bridge_v1_0_M00_AXIS_inst
       (.m00_axis_aclk(m00_axis_aclk),
        .m00_axis_aresetn(m00_axis_aresetn),
        .m00_axis_tdata(m00_axis_tdata),
        .m00_axis_tready(m00_axis_tready),
        .m00_axis_tvalid(m00_axis_tvalid));
fx3bridge_0_fx3bridge_v1_0_S00_AXIS__parameterized0 fx3bridge_v1_0_S00_AXIS_inst
       (.s00_axis_aclk(s00_axis_aclk),
        .s00_axis_aresetn(s00_axis_aresetn),
        .s00_axis_tlast(s00_axis_tlast),
        .s00_axis_tready(s00_axis_tready),
        .s00_axis_tvalid(s00_axis_tvalid));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
