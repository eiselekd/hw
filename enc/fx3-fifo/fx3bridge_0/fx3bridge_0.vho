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

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT fx3bridge_0
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
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : fx3bridge_0
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
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file fx3bridge_0.vhd when simulating
-- the core, fx3bridge_0. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

