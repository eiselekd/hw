// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.4 (win64) Build 1071353 Tue Nov 18 18:24:04 MST 2014
// Date        : Sun Jan 11 22:16:39 2015
// Host        : sol-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub c:/Users/sol/git/hw/enc/fx3-fifo/fx3bridge_0/fx3bridge_0_stub.v
// Design      : fx3bridge_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fx3bridge_v1_0,Vivado 2014.4" *)
module fx3bridge_0(FX3_Clk, FX3_SLCS_N, FX3_SlRd_N, FX3_SlWr_N, FX3_SlOe_N, FX3_Pktend_N, FX3_A, FX3_SlTri, FX3_DQ_o, FX3_DQ_i, FX3_FlagA, FX3_FlagB, m00_axis_tdata, m00_axis_tstrb, m00_axis_tlast, m00_axis_tvalid, m00_axis_tready, m00_axis_aclk, m00_axis_aresetn, s00_axis_tdata, s00_axis_tstrb, s00_axis_tlast, s00_axis_tvalid, s00_axis_tready, s00_axis_aclk, s00_axis_aresetn)
/* synthesis syn_black_box black_box_pad_pin="FX3_Clk,FX3_SLCS_N,FX3_SlRd_N,FX3_SlWr_N,FX3_SlOe_N,FX3_Pktend_N,FX3_A[1:0],FX3_SlTri,FX3_DQ_o[15:0],FX3_DQ_i[15:0],FX3_FlagA,FX3_FlagB,m00_axis_tdata[31:0],m00_axis_tstrb[3:0],m00_axis_tlast,m00_axis_tvalid,m00_axis_tready,m00_axis_aclk,m00_axis_aresetn,s00_axis_tdata[31:0],s00_axis_tstrb[3:0],s00_axis_tlast,s00_axis_tvalid,s00_axis_tready,s00_axis_aclk,s00_axis_aresetn" */;
  output FX3_Clk;
  output FX3_SLCS_N;
  output FX3_SlRd_N;
  output FX3_SlWr_N;
  output FX3_SlOe_N;
  output FX3_Pktend_N;
  output [1:0]FX3_A;
  output FX3_SlTri;
  output [15:0]FX3_DQ_o;
  input [15:0]FX3_DQ_i;
  input FX3_FlagA;
  input FX3_FlagB;
  output [31:0]m00_axis_tdata;
  output [3:0]m00_axis_tstrb;
  output m00_axis_tlast;
  output m00_axis_tvalid;
  input m00_axis_tready;
  input m00_axis_aclk;
  input m00_axis_aresetn;
  input [31:0]s00_axis_tdata;
  input [3:0]s00_axis_tstrb;
  input s00_axis_tlast;
  input s00_axis_tvalid;
  output s00_axis_tready;
  input s00_axis_aclk;
  input s00_axis_aresetn;
endmodule
