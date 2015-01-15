-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.4 (win64) Build 1071353 Tue Nov 18 18:24:04 MST 2014
-- Date        : Sun Jan 11 22:16:40 2015
-- Host        : sol-PC running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode funcsim c:/Users/sol/git/hw/enc/fx3-fifo/fx3bridge_0/fx3bridge_0_funcsim.vhdl
-- Design      : fx3bridge_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity \fx3bridge_0_fx3bridge_v1_0_M00_AXIS__parameterized0\ is
  port (
    m00_axis_tdata : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axis_tvalid : out STD_LOGIC;
    m00_axis_aclk : in STD_LOGIC;
    m00_axis_aresetn : in STD_LOGIC;
    m00_axis_tready : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of \fx3bridge_0_fx3bridge_v1_0_M00_AXIS__parameterized0\ : entity is "fx3bridge_v1_0_M00_AXIS";
end \fx3bridge_0_fx3bridge_v1_0_M00_AXIS__parameterized0\;

architecture STRUCTURE of \fx3bridge_0_fx3bridge_v1_0_M00_AXIS__parameterized0\ is
  signal clear : STD_LOGIC;
  signal \count_reg__0\ : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal \^m00_axis_tdata\ : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal mst_exec_state : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal n_0_axis_tvalid_delay_i_1 : STD_LOGIC;
  signal \n_0_count[2]_i_1\ : STD_LOGIC;
  signal \n_0_count[4]_i_1\ : STD_LOGIC;
  signal \n_0_mst_exec_state[0]_i_1\ : STD_LOGIC;
  signal \n_0_mst_exec_state[1]_i_1\ : STD_LOGIC;
  signal \n_0_mst_exec_state[1]_i_2\ : STD_LOGIC;
  signal \n_0_stream_data_out[0]_i_1\ : STD_LOGIC;
  signal \n_0_stream_data_out[1]_i_1\ : STD_LOGIC;
  signal \n_0_stream_data_out[2]_i_3\ : STD_LOGIC;
  signal plusOp : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal read_pointer : STD_LOGIC_VECTOR ( 0 to 0 );
  signal tx_en : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \count[0]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \count[1]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \count[2]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \count[3]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \count[4]_i_2\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \mst_exec_state[0]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \mst_exec_state[1]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \mst_exec_state[1]_i_2\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \stream_data_out[1]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \stream_data_out[2]_i_3\ : label is "soft_lutpair3";
begin
  m00_axis_tdata(2 downto 0) <= \^m00_axis_tdata\(2 downto 0);
axis_tvalid_delay_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
    port map (
      I0 => mst_exec_state(0),
      I1 => mst_exec_state(1),
      I2 => m00_axis_aresetn,
      O => n_0_axis_tvalid_delay_i_1
    );
axis_tvalid_delay_reg: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => '1',
      D => n_0_axis_tvalid_delay_i_1,
      Q => m00_axis_tvalid,
      R => '0'
    );
\count[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => \count_reg__0\(0),
      O => plusOp(0)
    );
\count[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => \count_reg__0\(0),
      I1 => \count_reg__0\(1),
      O => plusOp(1)
    );
\count[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
    port map (
      I0 => \count_reg__0\(0),
      I1 => \count_reg__0\(1),
      I2 => \count_reg__0\(2),
      O => \n_0_count[2]_i_1\
    );
\count[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
    port map (
      I0 => \count_reg__0\(1),
      I1 => \count_reg__0\(0),
      I2 => \count_reg__0\(2),
      I3 => \count_reg__0\(3),
      O => plusOp(3)
    );
\count[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
    port map (
      I0 => mst_exec_state(1),
      I1 => mst_exec_state(0),
      I2 => \n_0_mst_exec_state[1]_i_2\,
      O => \n_0_count[4]_i_1\
    );
\count[4]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
    port map (
      I0 => \count_reg__0\(2),
      I1 => \count_reg__0\(0),
      I2 => \count_reg__0\(1),
      I3 => \count_reg__0\(3),
      I4 => \count_reg__0\(4),
      O => plusOp(4)
    );
\count_reg[0]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => \n_0_count[4]_i_1\,
      D => plusOp(0),
      Q => \count_reg__0\(0),
      R => clear
    );
\count_reg[1]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => \n_0_count[4]_i_1\,
      D => plusOp(1),
      Q => \count_reg__0\(1),
      R => clear
    );
\count_reg[2]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => \n_0_count[4]_i_1\,
      D => \n_0_count[2]_i_1\,
      Q => \count_reg__0\(2),
      R => clear
    );
\count_reg[3]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => \n_0_count[4]_i_1\,
      D => plusOp(3),
      Q => \count_reg__0\(3),
      R => clear
    );
\count_reg[4]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => \n_0_count[4]_i_1\,
      D => plusOp(4),
      Q => \count_reg__0\(4),
      R => clear
    );
\mst_exec_state[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0D00"
    )
    port map (
      I0 => mst_exec_state(0),
      I1 => \n_0_mst_exec_state[1]_i_2\,
      I2 => mst_exec_state(1),
      I3 => m00_axis_aresetn,
      O => \n_0_mst_exec_state[0]_i_1\
    );
\mst_exec_state[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2600"
    )
    port map (
      I0 => mst_exec_state(1),
      I1 => mst_exec_state(0),
      I2 => \n_0_mst_exec_state[1]_i_2\,
      I3 => m00_axis_aresetn,
      O => \n_0_mst_exec_state[1]_i_1\
    );
\mst_exec_state[1]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFFFFFF"
    )
    port map (
      I0 => \count_reg__0\(4),
      I1 => \count_reg__0\(1),
      I2 => \count_reg__0\(0),
      I3 => \count_reg__0\(2),
      I4 => \count_reg__0\(3),
      O => \n_0_mst_exec_state[1]_i_2\
    );
\mst_exec_state_reg[0]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => '1',
      D => \n_0_mst_exec_state[0]_i_1\,
      Q => mst_exec_state(0),
      R => '0'
    );
\mst_exec_state_reg[1]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => '1',
      D => \n_0_mst_exec_state[1]_i_1\,
      Q => mst_exec_state(1),
      R => '0'
    );
\read_pointer_reg[0]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => \n_0_stream_data_out[0]_i_1\,
      Q => read_pointer(0),
      R => clear
    );
\stream_data_out[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => read_pointer(0),
      O => \n_0_stream_data_out[0]_i_1\
    );
\stream_data_out[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => read_pointer(0),
      I1 => \^m00_axis_tdata\(1),
      O => \n_0_stream_data_out[1]_i_1\
    );
\stream_data_out[2]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => m00_axis_aresetn,
      O => clear
    );
\stream_data_out[2]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => m00_axis_tready,
      I1 => mst_exec_state(1),
      I2 => mst_exec_state(0),
      O => tx_en
    );
\stream_data_out[2]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => \^m00_axis_tdata\(1),
      I1 => read_pointer(0),
      O => \n_0_stream_data_out[2]_i_3\
    );
\stream_data_out_reg[0]\: unisim.vcomponents.FDSE
    port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => \n_0_stream_data_out[0]_i_1\,
      Q => \^m00_axis_tdata\(0),
      S => clear
    );
\stream_data_out_reg[1]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => \n_0_stream_data_out[1]_i_1\,
      Q => \^m00_axis_tdata\(1),
      R => clear
    );
\stream_data_out_reg[2]\: unisim.vcomponents.FDRE
    port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => \n_0_stream_data_out[2]_i_3\,
      Q => \^m00_axis_tdata\(2),
      R => clear
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity \fx3bridge_0_fx3bridge_v1_0_S00_AXIS__parameterized0\ is
  port (
    s00_axis_tready : out STD_LOGIC;
    s00_axis_aclk : in STD_LOGIC;
    s00_axis_aresetn : in STD_LOGIC;
    s00_axis_tvalid : in STD_LOGIC;
    s00_axis_tlast : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of \fx3bridge_0_fx3bridge_v1_0_S00_AXIS__parameterized0\ : entity is "fx3bridge_v1_0_S00_AXIS";
end \fx3bridge_0_fx3bridge_v1_0_S00_AXIS__parameterized0\;

architecture STRUCTURE of \fx3bridge_0_fx3bridge_v1_0_S00_AXIS__parameterized0\ is
  signal n_0_mst_exec_state_i_1 : STD_LOGIC;
  signal n_0_writes_done_i_1 : STD_LOGIC;
  signal \^s00_axis_tready\ : STD_LOGIC;
  signal writes_done : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of mst_exec_state_i_1 : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of writes_done_i_1 : label is "soft_lutpair5";
begin
  s00_axis_tready <= \^s00_axis_tready\;
mst_exec_state_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"08A8"
    )
    port map (
      I0 => s00_axis_aresetn,
      I1 => s00_axis_tvalid,
      I2 => \^s00_axis_tready\,
      I3 => writes_done,
      O => n_0_mst_exec_state_i_1
    );
mst_exec_state_reg: unisim.vcomponents.FDRE
    port map (
      C => s00_axis_aclk,
      CE => '1',
      D => n_0_mst_exec_state_i_1,
      Q => \^s00_axis_tready\,
      R => '0'
    );
writes_done_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AA2AAA00"
    )
    port map (
      I0 => s00_axis_aresetn,
      I1 => s00_axis_tvalid,
      I2 => \^s00_axis_tready\,
      I3 => s00_axis_tlast,
      I4 => writes_done,
      O => n_0_writes_done_i_1
    );
writes_done_reg: unisim.vcomponents.FDRE
    port map (
      C => s00_axis_aclk,
      CE => '1',
      D => n_0_writes_done_i_1,
      Q => writes_done,
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity \fx3bridge_0_fx3bridge_v1_0__parameterized0\ is
  port (
    s00_axis_tready : out STD_LOGIC;
    m00_axis_tdata : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axis_tvalid : out STD_LOGIC;
    s00_axis_aresetn : in STD_LOGIC;
    s00_axis_tvalid : in STD_LOGIC;
    m00_axis_aresetn : in STD_LOGIC;
    m00_axis_aclk : in STD_LOGIC;
    m00_axis_tready : in STD_LOGIC;
    s00_axis_tlast : in STD_LOGIC;
    s00_axis_aclk : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of \fx3bridge_0_fx3bridge_v1_0__parameterized0\ : entity is "fx3bridge_v1_0";
end \fx3bridge_0_fx3bridge_v1_0__parameterized0\;

architecture STRUCTURE of \fx3bridge_0_fx3bridge_v1_0__parameterized0\ is
begin
fx3bridge_v1_0_M00_AXIS_inst: entity work.\fx3bridge_0_fx3bridge_v1_0_M00_AXIS__parameterized0\
    port map (
      m00_axis_aclk => m00_axis_aclk,
      m00_axis_aresetn => m00_axis_aresetn,
      m00_axis_tdata(2 downto 0) => m00_axis_tdata(2 downto 0),
      m00_axis_tready => m00_axis_tready,
      m00_axis_tvalid => m00_axis_tvalid
    );
fx3bridge_v1_0_S00_AXIS_inst: entity work.\fx3bridge_0_fx3bridge_v1_0_S00_AXIS__parameterized0\
    port map (
      s00_axis_aclk => s00_axis_aclk,
      s00_axis_aresetn => s00_axis_aresetn,
      s00_axis_tlast => s00_axis_tlast,
      s00_axis_tready => s00_axis_tready,
      s00_axis_tvalid => s00_axis_tvalid
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity fx3bridge_0 is
  port (
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
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of fx3bridge_0 : entity is true;
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of fx3bridge_0 : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of fx3bridge_0 : entity is "fx3bridge_v1_0,Vivado 2014.4";
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of fx3bridge_0 : entity is "fx3bridge_0,fx3bridge_v1_0,{}";
  attribute core_generation_info : string;
  attribute core_generation_info of fx3bridge_0 : entity is "fx3bridge_0,fx3bridge_v1_0,{x_ipProduct=Vivado 2014.4,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=fx3bridge,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,C_M00_AXIS_TDATA_WIDTH=32,C_M00_AXIS_START_COUNT=32,C_S00_AXIS_TDATA_WIDTH=32}";
end fx3bridge_0;

architecture STRUCTURE of fx3bridge_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \<const1>\ : STD_LOGIC;
  signal \^m00_axis_tdata\ : STD_LOGIC_VECTOR ( 2 downto 0 );
begin
  m00_axis_tdata(31) <= \<const0>\;
  m00_axis_tdata(30) <= \<const0>\;
  m00_axis_tdata(29) <= \<const0>\;
  m00_axis_tdata(28) <= \<const0>\;
  m00_axis_tdata(27) <= \<const0>\;
  m00_axis_tdata(26) <= \<const0>\;
  m00_axis_tdata(25) <= \<const0>\;
  m00_axis_tdata(24) <= \<const0>\;
  m00_axis_tdata(23) <= \<const0>\;
  m00_axis_tdata(22) <= \<const0>\;
  m00_axis_tdata(21) <= \<const0>\;
  m00_axis_tdata(20) <= \<const0>\;
  m00_axis_tdata(19) <= \<const0>\;
  m00_axis_tdata(18) <= \<const0>\;
  m00_axis_tdata(17) <= \<const0>\;
  m00_axis_tdata(16) <= \<const0>\;
  m00_axis_tdata(15) <= \<const0>\;
  m00_axis_tdata(14) <= \<const0>\;
  m00_axis_tdata(13) <= \<const0>\;
  m00_axis_tdata(12) <= \<const0>\;
  m00_axis_tdata(11) <= \<const0>\;
  m00_axis_tdata(10) <= \<const0>\;
  m00_axis_tdata(9) <= \<const0>\;
  m00_axis_tdata(8) <= \<const0>\;
  m00_axis_tdata(7) <= \<const0>\;
  m00_axis_tdata(6) <= \<const0>\;
  m00_axis_tdata(5) <= \<const0>\;
  m00_axis_tdata(4) <= \<const0>\;
  m00_axis_tdata(3) <= \<const0>\;
  m00_axis_tdata(2 downto 0) <= \^m00_axis_tdata\(2 downto 0);
  m00_axis_tlast <= \<const0>\;
  m00_axis_tstrb(3) <= \<const1>\;
  m00_axis_tstrb(2) <= \<const1>\;
  m00_axis_tstrb(1) <= \<const1>\;
  m00_axis_tstrb(0) <= \<const1>\;
  FX3_Clk <= 'Z';
  FX3_Pktend_N <= 'Z';
  FX3_SLCS_N <= 'Z';
  FX3_SlOe_N <= 'Z';
  FX3_SlRd_N <= 'Z';
  FX3_SlTri <= 'Z';
  FX3_SlWr_N <= 'Z';
  FX3_A(0) <= 'Z';
  FX3_A(1) <= 'Z';
  FX3_DQ_o(0) <= 'Z';
  FX3_DQ_o(1) <= 'Z';
  FX3_DQ_o(2) <= 'Z';
  FX3_DQ_o(3) <= 'Z';
  FX3_DQ_o(4) <= 'Z';
  FX3_DQ_o(5) <= 'Z';
  FX3_DQ_o(6) <= 'Z';
  FX3_DQ_o(7) <= 'Z';
  FX3_DQ_o(8) <= 'Z';
  FX3_DQ_o(9) <= 'Z';
  FX3_DQ_o(10) <= 'Z';
  FX3_DQ_o(11) <= 'Z';
  FX3_DQ_o(12) <= 'Z';
  FX3_DQ_o(13) <= 'Z';
  FX3_DQ_o(14) <= 'Z';
  FX3_DQ_o(15) <= 'Z';
GND: unisim.vcomponents.GND
    port map (
      G => \<const0>\
    );
U0: entity work.\fx3bridge_0_fx3bridge_v1_0__parameterized0\
    port map (
      m00_axis_aclk => m00_axis_aclk,
      m00_axis_aresetn => m00_axis_aresetn,
      m00_axis_tdata(2 downto 0) => \^m00_axis_tdata\(2 downto 0),
      m00_axis_tready => m00_axis_tready,
      m00_axis_tvalid => m00_axis_tvalid,
      s00_axis_aclk => s00_axis_aclk,
      s00_axis_aresetn => s00_axis_aresetn,
      s00_axis_tlast => s00_axis_tlast,
      s00_axis_tready => s00_axis_tready,
      s00_axis_tvalid => s00_axis_tvalid
    );
VCC: unisim.vcomponents.VCC
    port map (
      P => \<const1>\
    );
end STRUCTURE;
