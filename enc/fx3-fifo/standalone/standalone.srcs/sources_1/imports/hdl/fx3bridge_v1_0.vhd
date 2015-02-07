library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fx3_pkg.all;

entity fx3bridge is
	generic (
		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32;

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
        
        FX3_100mhz         : in std_logic;

        FX3_Clk             : out std_logic;
        FX3_A               : out std_logic_vector(1 downto 0);
        FX3_DQ_o            : out std_logic_vector(16-1 downto 0);
        FX3_DQ_i            : in  std_logic_vector(16-1 downto 0);
        FX3_FlagA           : in  std_logic;
        FX3_FlagB           : in  std_logic;
        FX3_SLCS_N          : out std_logic;  -- chip sel
        FX3_SlRd_N          : out std_logic;
        FX3_SlWr_N          : out std_logic;
        FX3_SlOe_N          : out std_logic;  -- tristate FX3 
        FX3_Pktend_N        : out std_logic;
        FX3_SlTri           : out std_logic;  -- tristate for DataIn/Out Pad, High word

        
        -- Do not modify the ports beyond this line
        axis_aclk	    : in std_logic;
        axis_aresetn	: in std_logic;

        -- Ports of Axi Master Bus Interface M00_AXIS
        m00_axis_tvalid	: out std_logic;
        m00_axis_tdata	: out std_logic_vector(31 downto 0);
        m00_axis_tlast	: out std_logic;
        m00_axis_tready	: in std_logic;

        -- Ports of Axi Slave Bus Interface S00_AXIS
        s00_axis_tready	: out std_logic;
        s00_axis_tdata	: in std_logic_vector(31 downto 0);
        s00_axis_tlast	: in std_logic;
        s00_axis_tvalid	: in std_logic
	);
end fx3bridge;

architecture arch_imp of fx3bridge is

  component clk_wiz_0 IS
    PORT (
      clk_in1    : IN STD_LOGIC;
      clk_out1    : IN STD_LOGIC
      );
  END component clk_wiz_0; 
        
      signal readfx3_s_axis_tvalid : STD_LOGIC;
      signal readfx3_s_axis_tready : STD_LOGIC;
      signal readfx3_s_axis_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
      signal readfx3_s_axis_tlast : STD_LOGIC;

      signal writefx3_m_axis_tvalid : STD_LOGIC;
      signal writefx3_m_axis_tready : STD_LOGIC;
      signal writefx3_m_axis_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
      signal writefx3_m_axis_tlast : STD_LOGIC;
  
    
  signal din : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal wr_en : STD_LOGIC;
  signal rd_en : STD_LOGIC;
  signal dout : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal           full :  STD_LOGIC;
  signal           almost_full :  STD_LOGIC;
  signal           empty :  STD_LOGIC;
  signal           almost_empty :  STD_LOGIC   ; 

  signal           FX3_270 :  STD_LOGIC   ; 

  constant	RdPort_c		:std_logic_vector(1 downto 0) := "00";
  constant	WrPort_c		:std_logic_vector(1 downto 0) := "10";

  type fx3_states is (fx3_idle, fx3_check_write, fx3_check_read, fx3_read, fx3_write, fx3_write_const);
  constant refresh_Cycles	: integer  := 6; -- Required refresh cycles after address change
  constant delayCounterSz : integer  := 4;
  

  type regs_sys is record
    sink_ready     : std_logic;
    sink_data      : std_logic_vector(31 downto 0);
    tohost_fifo_write : std_logic;
    rcnt          : std_logic_vector(31 downto 0);
    tcnt          : std_logic_vector(31 downto 0);
  end record;
  
  type regs_fx3 is record
    state         :  fx3_states;
    rcnt          :  std_logic_vector(31 downto 0);
    cnt           :  std_logic_vector(31 downto 0);
    delay         :  std_logic_vector(delayCounterSz-1 downto 0);

    FX3_SlRd_N    :  std_logic;
    FX3_SlWr_N	:  std_logic;
    FX3_SlOe_N    :  std_logic;
    FX3_SlTri_N    : std_logic;  -- tristate for DataIn/Out Pad, High word
    FX3_Pktend_N	:  std_logic;
    FX3_A1        :  std_logic;
    FX3_DQ_o      :  std_logic_vector(32-1 downto 0);
    
    tohost_fifo_read : std_logic;      
    dbg_out_state    : std_logic_vector(3 downto 0);
  end record;

  signal rsys, rsysin     : regs_sys;
  signal rfx3, rfx3in     : regs_fx3;
  signal tohost_fifo_read, tohost_fifo_haspacket, tohost_fifo_empty : std_logic;
  signal pack_size_len : std_logic_vector(15 downto 0);
  signal tohost_fifo_dataout : std_logic_vector(31 downto 0);
begin

  clk_wiz_0_inst : clk_wiz_0
  port map (
    clk_in1 => axis_aclk,
    clk_out1 => FX3_270 );
    
  ----------------------------------
  -- Fx3 100mhz clock domain -------
  ----------------------------------
  
  fx3 : process(axis_aclk, FX3_100mhz, axis_aresetn, rfx3,
                tohost_fifo_read, tohost_fifo_dataout, tohost_fifo_haspacket, tohost_fifo_empty,
                FX3_FlagA, FX3_FlagB )
    
    variable vfx3 : regs_fx3;
  begin
      
    vfx3 := rfx3;
    vfx3.cnt := (others => '0');
    vfx3.FX3_SlOe_N   := '1';
    vfx3.FX3_SlTri_N  := '1';
    vfx3.FX3_SlRd_N   := '1';
    vfx3.FX3_SlWr_N   := '1';
    vfx3.FX3_Pktend_N := '1';
    vfx3.tohost_fifo_read := '0';    
    vfx3.dbg_out_state := (others => '0');
    
    case rfx3.state is
      when fx3_idle =>
          
        vfx3.state := fx3_check_write; -- fx3_write_const; --fx3_check_write;
          
      when fx3_check_write =>
  
        vfx3.FX3_A1 := WrPort_c(1);
        vfx3.FX3_SlTri_N := '0';
        if (rfx3.cnt >= conv_std_logic_vector(refresh_Cycles, rfx3.cnt'length)) then
          if ((tohost_fifo_haspacket = '1') ) and (FX3_FlagB = '1')  then
            vfx3.state := fx3_write;
          else
            vfx3.state := fx3_check_read; --fx3_check_read;
          end if;
          vfx3.cnt := rfx3.cnt + 1;
        end if;

      when fx3_check_read =>
        
        vfx3.FX3_A1 := RdPort_c(1);
        vfx3.FX3_SlTri_N := '0';
        if (rfx3.cnt >= conv_std_logic_vector(refresh_Cycles, rfx3.cnt'length)) then
          if ((tohost_fifo_haspacket = '1') ) and (FX3_FlagA = '1')  then
            vfx3.state := fx3_read;
          else
            vfx3.state := fx3_idle;
          end if;
          vfx3.cnt := rfx3.cnt + 1;
        end if;

      when fx3_write =>             -- fpga -> Fx3
        if (rfx3.cnt(15 downto 0) >= ("0" & pack_size_len((16-1) downto 1)) )  then
          vfx3.state := fx3_check_read;
        else
          vfx3.cnt := rfx3.cnt + 1;
        end if;
  
        vfx3.tohost_fifo_read := rfx3.cnt(0);
        vfx3.FX3_SlWr_N := '0';
        vfx3.FX3_SlTri_N := '0';
          
        vfx3.FX3_DQ_o := tohost_fifo_dataout(32-1 downto 0);
        if rfx3.cnt(0) = '1' then
          vfx3.FX3_DQ_o(15 downto 0) := tohost_fifo_dataout(31 downto 16);
        end if;

          
      when fx3_read =>
        if (rfx3.cnt(15 downto 0) >= ("0" & pack_size_len((16-1) downto 1)) )  then
          vfx3.state := fx3_check_write;
        else
          vfx3.cnt := rfx3.cnt + 1;
        end if;
  
        vfx3.tohost_fifo_read := rfx3.cnt(0);
        vfx3.FX3_SlRd_N := '0';
        vfx3.FX3_SlOe_N := '0';
        
        if rfx3.cnt(0) = '1' then
          vfx3.FX3_DQ_o(15 downto 0) := tohost_fifo_dataout(31 downto 16);
        end if;
        
        
      when others => vfx3.state := fx3_idle;
    end case; 
      
    -- reset operation
    if (axis_aresetn = '0') then
      vfx3.rcnt := (others => '0'); vfx3.cnt := (others => '0');
      vfx3.FX3_SlRd_N := '1';  
      vfx3.FX3_SlWr_N := '1';  
      vfx3.FX3_SlOe_N := '1';  
      vfx3.FX3_SlTri_N := '1'; 
      vfx3.FX3_Pktend_N := '1';
      vfx3.FX3_A1 := '0';
      vfx3.state := fx3_idle;
    end if;
      
    rfx3in <= vfx3;
    
    FX3_SLCS_N     <= '0';
    FX3_SlRd_N     <= rfx3.FX3_SlRd_N;
    FX3_SlWr_N     <= rfx3.FX3_SlWr_N;
    FX3_SlOe_N     <= rfx3.FX3_SlOe_N;
    FX3_SlTri      <= rfx3.FX3_SlTri_N;
    FX3_Pktend_N   <= rfx3.FX3_Pktend_N;
    FX3_A          <= rfx3.FX3_A1 & '0';      
    FX3_DQ_o       <= rfx3.FX3_DQ_o(16-1 downto 0);
    
    tohost_fifo_read <= vfx3.tohost_fifo_read;
    
  end process;

  readfx3_mwritefpga :  fifo_generator_0 
    port map (
      m_aclk => axis_aclk,
      s_aclk => FX3_100mhz,
      s_aresetn => axis_aresetn,
      
      s_axis_tvalid => readfx3_s_axis_tvalid,
      s_axis_tready => readfx3_s_axis_tready,
      s_axis_tdata => readfx3_s_axis_tdata,
      s_axis_tlast => readfx3_s_axis_tlast,
      
      m_axis_tvalid => m00_axis_tvalid,
      m_axis_tready => m00_axis_tready,
      m_axis_tdata => m00_axis_tdata,
      m_axis_tlast => m00_axis_tlast
      );

  writefx3_sreadfpga : fifo_generator_0 
    port map (
      m_aclk => FX3_100mhz,
      s_aclk  => axis_aclk,
      s_aresetn => axis_aresetn,
      
      s_axis_tvalid => s00_axis_tvalid,
      s_axis_tready => s00_axis_tready,
      s_axis_tdata => s00_axis_tdata,
      s_axis_tlast => s00_axis_tlast,
      
      m_axis_tvalid => writefx3_m_axis_tvalid,
      m_axis_tready => writefx3_m_axis_tready,
      m_axis_tdata => writefx3_m_axis_tdata,
      m_axis_tlast => writefx3_m_axis_tlast
      );
  
end arch_imp;

