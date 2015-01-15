-- (c) Copyright 1995-2015 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:user:fx3bridge:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fx3bridge_0 IS
  PORT (
    FX3_Clk : OUT STD_LOGIC;
    FX3_SLCS_N : OUT STD_LOGIC;
    FX3_SlRd_N : OUT STD_LOGIC;
    FX3_SlWr_N : OUT STD_LOGIC;
    FX3_SlOe_N : OUT STD_LOGIC;
    FX3_Pktend_N : OUT STD_LOGIC;
    FX3_A : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    FX3_SlTri : OUT STD_LOGIC;
    FX3_DQ_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    FX3_DQ_i : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    FX3_FlagA : IN STD_LOGIC;
    FX3_FlagB : IN STD_LOGIC;
    m00_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m00_axis_tstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m00_axis_tlast : OUT STD_LOGIC;
    m00_axis_tvalid : OUT STD_LOGIC;
    m00_axis_tready : IN STD_LOGIC;
    m00_axis_aclk : IN STD_LOGIC;
    m00_axis_aresetn : IN STD_LOGIC;
    s00_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axis_tstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s00_axis_tlast : IN STD_LOGIC;
    s00_axis_tvalid : IN STD_LOGIC;
    s00_axis_tready : OUT STD_LOGIC;
    s00_axis_aclk : IN STD_LOGIC;
    s00_axis_aresetn : IN STD_LOGIC
  );
END fx3bridge_0;

ARCHITECTURE fx3bridge_0_arch OF fx3bridge_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : string;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF fx3bridge_0_arch: ARCHITECTURE IS "yes";

  COMPONENT fx3bridge_v1_0 IS
    GENERIC (
      C_M00_AXIS_TDATA_WIDTH : INTEGER; -- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
      C_M00_AXIS_START_COUNT : INTEGER; -- Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.
      C_S00_AXIS_TDATA_WIDTH : INTEGER -- AXI4Stream sink: Data Width
    );
    PORT (
      FX3_Clk : OUT STD_LOGIC;
      FX3_SLCS_N : OUT STD_LOGIC;
      FX3_SlRd_N : OUT STD_LOGIC;
      FX3_SlWr_N : OUT STD_LOGIC;
      FX3_SlOe_N : OUT STD_LOGIC;
      FX3_Pktend_N : OUT STD_LOGIC;
      FX3_A : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      FX3_SlTri : OUT STD_LOGIC;
      FX3_DQ_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      FX3_DQ_i : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      FX3_FlagA : IN STD_LOGIC;
      FX3_FlagB : IN STD_LOGIC;
      m00_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m00_axis_tstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m00_axis_tlast : OUT STD_LOGIC;
      m00_axis_tvalid : OUT STD_LOGIC;
      m00_axis_tready : IN STD_LOGIC;
      m00_axis_aclk : IN STD_LOGIC;
      m00_axis_aresetn : IN STD_LOGIC;
      s00_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axis_tstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s00_axis_tlast : IN STD_LOGIC;
      s00_axis_tvalid : IN STD_LOGIC;
      s00_axis_tready : OUT STD_LOGIC;
      s00_axis_aclk : IN STD_LOGIC;
      s00_axis_aresetn : IN STD_LOGIC
    );
  END COMPONENT fx3bridge_v1_0;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF fx3bridge_0_arch: ARCHITECTURE IS "fx3bridge_v1_0,Vivado 2014.4";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF fx3bridge_0_arch : ARCHITECTURE IS "fx3bridge_0,fx3bridge_v1_0,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF fx3bridge_0_arch: ARCHITECTURE IS "fx3bridge_0,fx3bridge_v1_0,{x_ipProduct=Vivado 2014.4,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=fx3bridge,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,C_M00_AXIS_TDATA_WIDTH=32,C_M00_AXIS_START_COUNT=32,C_S00_AXIS_TDATA_WIDTH=32}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF FX3_Clk: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_Clk";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_SLCS_N: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SLCS_N";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_SlRd_N: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SlRd_N";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_SlWr_N: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SlWr_N";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_SlOe_N: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SlOe_N";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_Pktend_N: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_Pktend_N";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_A: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_A";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_SlTri: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_SlTri";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_DQ_o: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_DQ_o";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_DQ_i: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_DQ_i";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_FlagA: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_FlagA";
  ATTRIBUTE X_INTERFACE_INFO OF FX3_FlagB: SIGNAL IS "xilinx.com:interface:fx3interface:1.0 FX3_Pktend_N FX3_FlagB";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tstrb: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 M00_AXIS_CLK CLK";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 M00_AXIS_RST RST";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tstrb: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 S00_AXIS_CLK CLK";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 S00_AXIS_RST RST";
BEGIN
  U0 : fx3bridge_v1_0
    GENERIC MAP (
      C_M00_AXIS_TDATA_WIDTH => 32,
      C_M00_AXIS_START_COUNT => 32,
      C_S00_AXIS_TDATA_WIDTH => 32
    )
    PORT MAP (
      FX3_Clk => FX3_Clk,
      FX3_SLCS_N => FX3_SLCS_N,
      FX3_SlRd_N => FX3_SlRd_N,
      FX3_SlWr_N => FX3_SlWr_N,
      FX3_SlOe_N => FX3_SlOe_N,
      FX3_Pktend_N => FX3_Pktend_N,
      FX3_A => FX3_A,
      FX3_SlTri => FX3_SlTri,
      FX3_DQ_o => FX3_DQ_o,
      FX3_DQ_i => FX3_DQ_i,
      FX3_FlagA => FX3_FlagA,
      FX3_FlagB => FX3_FlagB,
      m00_axis_tdata => m00_axis_tdata,
      m00_axis_tstrb => m00_axis_tstrb,
      m00_axis_tlast => m00_axis_tlast,
      m00_axis_tvalid => m00_axis_tvalid,
      m00_axis_tready => m00_axis_tready,
      m00_axis_aclk => m00_axis_aclk,
      m00_axis_aresetn => m00_axis_aresetn,
      s00_axis_tdata => s00_axis_tdata,
      s00_axis_tstrb => s00_axis_tstrb,
      s00_axis_tlast => s00_axis_tlast,
      s00_axis_tvalid => s00_axis_tvalid,
      s00_axis_tready => s00_axis_tready,
      s00_axis_aclk => s00_axis_aclk,
      s00_axis_aresetn => s00_axis_aresetn
    );
END fx3bridge_0_arch;
