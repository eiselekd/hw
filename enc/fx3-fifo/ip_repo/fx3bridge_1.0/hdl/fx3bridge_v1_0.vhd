library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fx3bridge is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32;

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (



		-- Users to add ports here
        FX3_100mhz    : in std_logic;

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

		-- User ports ends
		-- Do not modify the ports beyond this line
		axis_aclk	: in std_logic;
		axis_aresetn	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
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
        
     component fifo_generator_0 IS
      PORT (
        rst    : IN STD_LOGIC;
        wr_clk : IN STD_LOGIC;
        rd_clk : IN STD_LOGIC;
        din    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wr_en  : IN STD_LOGIC;FX3_SlTri
        rd_en  : IN STD_LOGIC;
        dout   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        full   : OUT STD_LOGIC;
        almost_full : OUT STD_LOGIC;
        empty  : OUT STD_LOGIC;
        almost_empty : OUT STD_LOGIC
      );
      END component fifo_generator_0;     
    
signal din : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal           wr_en : STD_LOGIC;
signal           rd_en : STD_LOGIC;
signal           dout : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal           full :  STD_LOGIC;FX3_100mhz
signal           almost_full :  STD_LOGIC;
signal           empty :  STD_LOGIC;
signal           almost_empty :  STD_LOGIC   ; 

signal           FX3_270 :  STD_LOGIC   ; 
    
begin

  clk_wiz_0_inst : clk_wiz_0
  port map (
    clk_in1 => axis_aclk,
    clk_out1 => FX3_270 );
    
  fifo_generator_0_inst : fifo_generator_0 
  port map (
      rst => axis_aresetn,
      wr_clk => axis_aclk,
      rd_clk => axis_aclk,
      din => din,
      wr_en => wr_en,
      rd_en => rd_en,
      dout => dout,
      full => full,
      almost_full => almost_full,
      empty => empty,
      almost_empty => almost_empty
    );   
  

	-- Add user logic here
    ----------------------------------
    -- Fx3 100mhz clock domain -------
    ----------------------------------
    
    fx3 : process(av_clk, FX3_100mhz, rstn, rfx3,
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
          vfx3.dbg_out_state := "0001";
  
          vfx3.FX3_A1 := WrPort_c(1);
          vfx3.FX3_SlTri_N := '0';
          if (rfx3.cnt >= conv_std_logic_vector(refresh_Cycles, rfx3.cnt'length)) then
            if ((tohost_fifo_haspacket = '1') or (pattern_gen = '1')) and (FX3_FlagB = '1')  then
              vfx3.state := fx3_write;
            else
              vfx3.state := fx3_idle; --fx3_check_read;
            end if;
          elseaxis_aresetn
            vfx3.cnt := rfx3.cnt + 1;
          end if;
        when fx3_write =>             -- fpga -> Fx3
          vfx3.dbg_out_state := "0010";
          if (rfx3.cnt(15 downto 0) >= ("0" & pack_size_len((16-1) downto 1)) )  then
            vfx3.state := fx3_check_write;
          else
            vfx3.cnt := rfx3.cnt + 1;
          end if;
  
          if gpif_is_16bit='1' then
            vfx3.tohost_fifo_read := rfx3.cnt(0);
          else
            vfx3.tohost_fifo_read := '1';
          end if;
          vfx3.FX3_SlWr_N := '0';
          vfx3.FX3_SlTri_N := '0';
          
          vfx3.FX3_DQ_o := tohost_fifo_dataout(32-1 downto 0);
          if gpif_is_16bit='1' and rfx3.cnt(0) = '1' then
            vfx3.FX3_DQ_o(15 downto 0) := tohost_fifo_dataout(31 downto 16);
          end if;
          
        when fx3_write_const =>       -- fpga -> Fx3
          vfx3.dbg_out_state := "0011";
          
          vfx3.tohost_fifo_read := '1';
          if (FX3_FlagB = '1') then
            vfx3.FX3_SlWr_N := '0';
            vfx3.FX3_SlTri_N := '0';
          end if;
          vfx3.FX3_DQ_o := tohost_fifo_dataout(32-1 downto 0);
          
        when others => vfx3.state := fx3_idle;
      end case; 
      
      -- reset operation
      if (rstn = '0') then
        vfx3.rcnt := (others => '0'); vfx3.cnt := (others => '0');
        vfx3.FX3_SlRd_N := '1';  
        vfx3.FX3_SlWr_N := '1';  
        vfx3.FX3_SlOe_N := '1';  
        vfx3.FX3_SlTri_N := '1'; 
        vfx3.FX3_Pktend_N := '1';
        vfx3.FX3_A1 := '0';
        vfx3.state := fx3_idle;
      end if;
      
      -- update registers
      rfx3in <= vfx3;
     
      FX3_SLCS_N   <= '0';
      FX3_SlRd_N   <= rfx3.FX3_SlRd_N;
      FX3_SlWr_N     <= rfx3.FX3_SlWr_N;
      FX3_SlOe_N   <= rfx3.FX3_SlOe_N;
      FX3_SlTri  <= rfx3.FX3_SlTri_N;
      FX3_SlTri_L_N  <= rfx3.FX3_SlTri_N;
      FX3_Pktend_N <= rfx3.FX3_Pktend_N;
      FX3_A(0)     <= '0';      
      FX3_A(1)     <= rfx3.FX3_A1;      
      FX3_DQ_o     <= rfx3.FX3_DQ_o(32-1 downto 0);
      
      tohost_fifo_read <= vfx3.tohost_fifo_read;
      
      FX3DBG_state <= vfx3.dbg_out_state;
      FX3DBG_tohost_fifo_haspacket <= tohost_fifo_haspacket;
      FX3DBG_cnt <= rfx3.cnt;
      
    end process;
    
	-- User logic ends

end arch_imp;
