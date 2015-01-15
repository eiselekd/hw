-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.4 (win64) Build 1071353 Tue Nov 18 18:24:04 MST 2014
-- Date        : Sun Jan 11 22:16:39 2015
-- Host        : sol-PC running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub c:/Users/sol/git/hw/enc/fx3-fifo/fx3bridge_0/fx3bridge_0_stub.vhdl
-- Design      : fx3bridge_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fx3bridge_0 is
  Port ( 
    FX3_Clk : out STD_LOGIC;
    FX3_SLCS_N : out STD_LOGIC;
    FX3_SlRd_N : out STD_LOGIC;
    FX3_SlWr_N : out STD_LOGIC;
    FX3_SlOe_N : out STD_LOGIC;
    FX3_Pktend_N : out STD_LOGIC;
    FX3_A : out STD_LOGIC_VECTOR ( 1 downto 0 );
    FX3_SlTri : out STD_LOGIC;
    FX3_DQ_o : out STD_LOGIC_VECTOR ( 15 downto 0 );
    FX3_DQ_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    FX3_FlagA : in STD_LOGIC;
    FX3_FlagB : in STD_LOGIC;
    m00_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axis_tstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axis_tlast : out STD_LOGIC;
    m00_axis_tvalid : out STD_LOGIC;
    m00_axis_tready : in STD_LOGIC;
    m00_axis_aclk : in STD_LOGIC;
    m00_axis_aresetn : in STD_LOGIC;
    s00_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axis_tstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s00_axis_tlast : in STD_LOGIC;
    s00_axis_tvalid : in STD_LOGIC;
    s00_axis_tready : out STD_LOGIC;
    s00_axis_aclk : in STD_LOGIC;
    s00_axis_aresetn : in STD_LOGIC
  );

end fx3bridge_0;

architecture stub of fx3bridge_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "FX3_Clk,FX3_SLCS_N,FX3_SlRd_N,FX3_SlWr_N,FX3_SlOe_N,FX3_Pktend_N,FX3_A[1:0],FX3_SlTri,FX3_DQ_o[15:0],FX3_DQ_i[15:0],FX3_FlagA,FX3_FlagB,m00_axis_tdata[31:0],m00_axis_tstrb[3:0],m00_axis_tlast,m00_axis_tvalid,m00_axis_tready,m00_axis_aclk,m00_axis_aresetn,s00_axis_tdata[31:0],s00_axis_tstrb[3:0],s00_axis_tlast,s00_axis_tvalid,s00_axis_tready,s00_axis_aclk,s00_axis_aresetn";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fx3bridge_v1_0,Vivado 2014.4";
begin
end;
