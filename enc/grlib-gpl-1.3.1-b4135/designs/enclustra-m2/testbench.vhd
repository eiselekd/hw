-----------------------------------------------------------------------------
--  LEON3 Demonstration design test bench
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2013, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

library gaisler;
use gaisler.libdcom.all;
use gaisler.sim.all;
library techmap;
use techmap.gencomp.all;
use work.debug.all;
library hynix;
use hynix.components.all;
library grlib;
use grlib.stdlib.all;

use work.config.all;	-- configuration

entity testbench is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;

    clkperiod : integer := 20;		-- system clock period
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 16;		-- rom address depth
    sramwidth  : integer := 32;		-- ram data width (8/16/32)
    sramdepth  : integer := 18;		-- ram address depth
    srambanks  : integer := 2;		-- number of ram banks
    iflen      : integer := 32
  );
end; 

architecture behav of testbench is

constant promfile  : string := "prom.srec";  -- rom contents
constant sramfile  : string := "ram.srec";  -- ram contents
constant sdramfile : string := "ram.srec"; -- sdram contents

signal clk : std_logic := '0';
signal Rst : std_logic := '0';			-- Reset
constant ct : integer := clkperiod/2;

signal address  : std_logic_vector(24 downto 0);
signal data     : std_logic_vector(31 downto 24);
signal pio     	: std_logic_vector(17 downto 0);
signal genio   	: std_logic_vector(59 downto 0);
signal romsn  	: std_logic;
signal oen      : std_ulogic;
signal writen   : std_ulogic;
signal GND      : std_ulogic := '0';
signal VCC      : std_ulogic := '1';
signal NC       : std_ulogic := 'Z';
signal wdogn    : std_logic;
    

signal erx_dv, erx_dv_d, etx_en: std_logic:='0';
signal erxd, erxd_d, etxd: std_logic_vector(7 downto 0):=(others=>'0');
signal emdc, emdio: std_logic; --dummy signal for the mdc,mdio in the phy which is not used
signal emdint : std_ulogic;
signal etx_clk : std_ulogic;
signal erx_clk : std_ulogic := '0';

signal ps2clk      : std_logic_vector(1 downto 0);
signal ps2data     : std_logic_vector(1 downto 0);

signal clk2        : std_ulogic := '0';
signal clk125      : std_ulogic := '0';

signal iic_scl       : std_ulogic;
signal iic_sda       : std_ulogic;
signal ddc_scl       : std_ulogic;
signal ddc_sda       : std_ulogic;
signal dvi_iic_scl   : std_logic;
signal dvi_iic_sda   : std_logic;

signal spw_clk	: std_ulogic := '0';
signal spw_rxdp : std_logic_vector(0 to CFG_SPW_NUM-1) := (others => '0');
signal spw_rxdn : std_logic_vector(0 to CFG_SPW_NUM-1) := (others => '0');
signal spw_rxsp : std_logic_vector(0 to CFG_SPW_NUM-1) := (others => '0');
signal spw_rxsn : std_logic_vector(0 to CFG_SPW_NUM-1) := (others => '0');
signal spw_txdp : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txdn : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txsp : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txsn : std_logic_vector(0 to CFG_SPW_NUM-1);

signal tft_lcd_data    : std_logic_vector(11 downto 0);
signal tft_lcd_clk_p   : std_ulogic;
signal tft_lcd_clk_n   : std_ulogic;
signal tft_lcd_hsync   : std_ulogic;
signal tft_lcd_vsync   : std_ulogic;
signal tft_lcd_de      : std_ulogic;
signal tft_lcd_reset_b : std_ulogic;

  -- DDR2 memory
  signal ddr_clk    : std_logic;
  signal ddr_clkb   : std_logic;
  signal ddr_clk_fb : std_logic;
  signal ddr_cke    : std_logic;
  signal ddr_csb    : std_logic := '0';
  signal ddr_we     : std_ulogic;                       -- write enable
  signal ddr_ras    : std_ulogic;                       -- ras
  signal ddr_cas    : std_ulogic;                       -- cas
  signal ddr_dm     : std_logic_vector(1 downto 0);     -- dm
  signal ddr_dqs    : std_logic_vector(1 downto 0);     -- dqs
  signal ddr_dqsn   : std_logic_vector(1 downto 0);     -- dqsn
  signal ddr_ad     : std_logic_vector(12 downto 0);    -- address
  signal ddr_ba     : std_logic_vector(2 downto 0);     -- bank address
  signal ddr_dq     : std_logic_vector(15 downto 0);    -- data
  signal ddr_dq2    : std_logic_vector(15 downto 0);    -- data
  signal ddr_odt    : std_logic;
  signal ddr_rzq    : std_logic;
  signal ddr_zio    : std_logic;
  

    -- SPI flash
  signal spi_sel_n : std_ulogic;
  signal spi_clk   : std_ulogic;
  signal spi_mosi  : std_ulogic;

  signal dsurst  : std_ulogic;
  signal errorn  : std_logic;

signal switch       : std_logic_vector(9 downto 0);    -- I/O port
signal led          : std_logic_vector(3 downto 0);    -- I/O port
  signal erx_er  : std_logic := '0';
  signal erx_col  : std_logic := '0';
  signal erx_crs  : std_logic := '1';
  signal etx_er  : std_logic := '0';



		-- clock / reset interface
signal		Clk_50				: std_logic;
		
signal		RESET_N				: std_logic; 

		-- EZ-USB FX3 slave FIFO interface
signal		FX3_Clk				: std_logic;
signal		FX3_SlRd_N			: std_logic;
signal		FX3_SlWr_N			: std_logic;
signal		FX3_SlOe_N			: std_logic;
signal		FX3_Pktend_N		        : std_logic;
signal		FX3_A1				: std_logic;
signal		FX3_DQ				: std_logic_vector(iflen-1 downto 0);
signal		FX3_FlagA			: std_logic := '0';
signal		FX3_FlagB			: std_logic := '0';
		
		-- Ethernet interface
signal		Eth_Rst_N			: std_logic;
		
		-- I2C interface
signal		I2c_Int_N			: std_logic;
signal		I2c_Scl				: std_logic;
signal		I2c_Sda				: std_logic;
	
		-- SPI Flash interface
signal		Flash_Clk			: std_logic;
signal		Flash_Cs_N			: std_logic;
signal		Flash_Do			: std_logic;
signal		Flash_Di			: std_logic;
signal		Flash_Hold_N	     	        : std_logic;
signal		Flash_Wp_N			: std_logic;

signal    txd1        : std_logic;          -- UART1 tx data
signal    rxd1        : std_logic;           -- UART1 rx data
signal    ctsn1       : std_ulogic;           -- UART1 ctsn
signal    rtsn1       : std_ulogic;           -- UART1 trsn
signal    txd2        : std_logic;          -- UART2 tx data
signal    rxd2        : std_logic;           -- UART2 rx data
signal    ctsn2       : std_ulogic;           -- UART2 ctsn
signal    rtsn2       : std_ulogic;           -- UART2 rtsn

		-- Led interface
signal		Led_N				: std_logic_vector (3 downto 0);
signal    startRx : std_logic := '0';

signal out_data				: std_logic_vector(31 downto 0);

constant lresp : boolean := false;
signal FX3_A				: std_logic_vector(1 downto 0);
		
begin

-- clock and reset

  clk  <= not clk after ct * 1 ns;
  clk125  <= not clk125 after 4 ns;
  Clk_50 <= clk;
  --erx_clk <= not erx_clk after 4 ns;
  clk2 <= '0'; --not clk2 after 5 ns;
  rst <= dsurst and wdogn; 
  rxd1 <= 'H'; ctsn1 <= '0';
  rxd2 <= 'H'; ctsn2 <= '0';
  ps2clk <= "HH"; ps2data <= "HH";
  pio(4) <= pio(5); pio(1) <= pio(2); pio <= (others => 'H');
  wdogn <= 'H';
  switch(7) <= '1';
  switch(8) <= '0';
  emdio <= 'H';

  spw_rxdp <= spw_txdp; spw_rxdn <= spw_txdn;
  spw_rxsp <= spw_txsp; spw_rxsn <= spw_txsn;

  RESET_N <= rst;

        e_proc: process
	begin
		FX3_DQ <= (others => 'Z');	
		wait until RESET_N = '1';
		while true loop
			wait until rising_edge(FX3_Clk);
			wait for 8 ns;
			if FX3_SlOe_N = '0' then
				FX3_DQ <= out_data;		
			else
				FX3_DQ <= (others => 'Z');			
			end if;
		end loop;
	end process;

  
  fx3sim : process
    procedure read_data_from_fpga(thread_addr: in integer; repeat: in integer; success: out boolean) is
      variable data_count: integer := 0;
    begin
      success := true;
      while data_count < repeat loop
        wait until rising_edge(FX3_Clk);
        
        if (FX3_SlWr_N = '0') and (FX3_A = thread_addr) then
          if FX3_DQ /= data_count then
            success := false;
          end if;
          data_count := data_count + 1;
        end if;
        
        wait for 8 ns;	
        
        if FX3_A = thread_addr and data_count < repeat then
          FX3_FLAGB <= '1';
        else
          FX3_FLAGB <= '0';
        end if;
        
      end loop;
      
      wait until rising_edge(FX3_Clk);
      wait for 8 ns;
      FX3_FLAGB <= '0';
      wait for 1 us;			
    end procedure read_data_from_fpga;

    variable packetcnt : integer := 0;
    variable success: boolean;
  begin
    wait until startRx = '1';
    
    -- 16 packets a 512
    while packetcnt < 16 loop
      read_data_from_fpga(2, 512, success);
      assert success = true report "Read data failure" severity failure;
    end loop;
    
    wait;
  end process;


   cpu : entity work.leon3mp
       generic map ( fabtech, memtech, padtech, clktech, 
         disas, dbguart, pclow, iflen )
       port map (

                 -- clock / reset interface
                 Clk_50          => Clk_50,			       
                 RESET_N         => RESET_N,				

                 -- EZ-USB FX3 slave FIFO interface
                 FX3_Clk		=> FX3_Clk,				
                 FX3_SlRd_N	=> FX3_SlRd_N,			
                 FX3_SlWr_N	=> FX3_SlWr_N,			
                 FX3_SlOe_N	=> FX3_SlOe_N,			
                 FX3_Pktend_N	=> FX3_Pktend_N,		        
                 FX3_A1		=> FX3_A1,				
                 FX3_DQ		=> FX3_DQ,				
                 FX3_FlagA	=> FX3_FlagA,			
                 FX3_FlagB	=> FX3_FlagB,			

                 -- Ethernet interface
                 Eth_Rst_N       => Eth_Rst_N,			

                 -- I2C interface
                 I2c_Int_N	=> I2c_Int_N,			
                 I2c_Scl		=> I2c_Scl,				
                 I2c_Sda		=> I2c_Sda,				

                 -- SPI Flash interface
                 Flash_Clk	=> Flash_Clk,			
                 Flash_Cs_N	=> Flash_Cs_N,			
                 Flash_Do	=> Flash_Do,			
                 Flash_Di	=> Flash_Di,			
                 Flash_Hold_N	=> Flash_Hold_N,	     	        
                 Flash_Wp_N	=> Flash_Wp_N,			

  -- pragma translate_off
                 -- UART

     txd1   => txd1,      
     rxd1   => rxd1,      
     ctsn1  => ctsn1,     
     rtsn1  => rtsn1,     
     txd2   => txd2,      
     rxd2   => rxd2,      
     ctsn2  => ctsn2,     
     rtsn2  => rtsn2,     


  -- pragma translate_on

                 -- Led interface
                 Led_N		=> Led_N
                 );



   FX3_A <= FX3_A1 & '0';


       --  rst, clk, clk2, clk125, wdogn, address(24 downto 0), data, 
       --  oen, writen, romsn,
       --  ddr_clk, ddr_clkb, ddr_cke, ddr_odt, ddr_we, ddr_ras, ddr_csb ,ddr_cas, ddr_dm,
       --  ddr_dqs, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq, ddr_rzq, ddr_zio,
       --  txd1, rxd1, ctsn1, rtsn1, txd2, rxd2, ctsn2, rtsn2, pio, genio,
       --  switch, led, erx_clk, emdio, erxd(3 downto 0)'delayed(1 ns), erx_dv'delayed(1 ns), emdint,
       --  etx_clk, etxd(3 downto 0), etx_en, emdc, 
       --  ps2clk, ps2data, iic_scl, iic_sda, ddc_scl, ddc_sda,
       --  dvi_iic_scl, dvi_iic_sda,
       --  tft_lcd_data, tft_lcd_clk_p, tft_lcd_clk_n, tft_lcd_hsync,
       --  tft_lcd_vsync, tft_lcd_de, tft_lcd_reset_b,
       --  spw_clk, spw_rxdp, spw_rxdn,
       --  spw_rxsp,  spw_rxsn, spw_txdp, spw_txdn, spw_txsp, spw_txsn, 
       --  spi_sel_n, spi_clk, spi_mosi
       --);

   prom0 : sram generic map (index => 6, abits => romdepth, fname => promfile)
         port map (address(romdepth-1 downto 0), data(31 downto 24), romsn,
                   writen, oen);

   ddr2mem : if (CFG_MIG_DDR2 = 1) generate 
     ddr2mem0 : for i in 0 to 0 generate
       u1 : HY5PS121621F
         generic map (TimingCheckFlag => false, PUSCheckFlag => false,
                      index => i, bbits => 16, fname => sdramfile, fdelay => 340)
         port map (DQ => ddr_dq(i*16+15 downto i*16),
                   LDQS  => ddr_dqs(i*2), LDQSB => ddr_dqsn(i*2),
                   UDQS => ddr_dqs(i*2+1), UDQSB => ddr_dqsn(i*2+1),
                   LDM => ddr_dm(i*2), WEB => ddr_we, CASB => ddr_cas,
                   RASB => ddr_ras, CSB => ddr_csb, BA => ddr_ba(1 downto 0),
                   ADDR => ddr_ad(12 downto 0), CKE => ddr_cke,
                   CLK => ddr_clk, CLKB => ddr_clkb, UDM => ddr_dm(i*2+1));
     end generate;
   end generate;

   ps2devs: for i in 0 to 1 generate
     ps2_device(ps2clk(i), ps2data(i));
   end generate ps2devs;

   errorn <= led_n(1);
   errorn <= 'H';			  -- ERROR pull-up

   phy0 : if (CFG_GRETH = 1) generate
     emdio <= 'H'; 
     p0: phy
       generic map(address => 1)
       port map(rst, emdio, open, erx_clk, erxd_d, erx_dv_d,
         erx_er, erx_col, erx_crs, etxd, etx_en, etx_er, emdc, clk125);
   end generate;

   rcxclkp : process(erx_clk) is
   begin
       erxd   <= erxd_d;
       erx_dv <= erx_dv_d;
   end process;


   data <= buskeep(data) after 5 ns;

   dsucom : process
     procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
     variable w32 : std_logic_vector(31 downto 0);
     variable c8  : std_logic_vector(7 downto 0);
     constant txp : time := 320 * 1 ns;
     begin
     startRx <= '0';
    dsutx <= '1';
    dsurst <= '0';
    wait for 201 us;
    wait for 2500 ns;
    dsurst <= '1';
    wait for 5000 ns;
    txc(dsutx, 16#55#, txp);		-- sync uart

--    txc(dsutx, 16#c0#, txp);
--    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
--    txa(dsutx, 16#00#, 16#00#, 16#20#, 16#2e#, txp);

    wait for 25000 ns;
    -- wmem 0x80000504 512 (0x200) = psz
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#80#, 16#00#, 16#05#, 16#04#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#02#, 16#00#, txp);
    -- wmem 0x80000508 16 (0x10) = pidx
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#80#, 16#00#, 16#05#, 16#08#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#10#, txp);

    -- wmem 0x80000500 1 = start
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#80#, 16#00#, 16#05#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#01#, txp);

    startRx <= '1';
    wait for 2500000 ns;
    
    wait;
    end;

  begin

    dsucfg(txd2, rxd2);

    wait;
  end process;

  iuerr : process
  begin
    wait until dsurst = '1';
    wait for 5000 ns;
    --if to_x01(errorn) = '1' then wait on errorn; end if;
    --assert (to_x01(errorn) = '1') 
    --  report "*** IU in error mode, simulation halted ***"
    --  severity failure ;
  end process;

end ;

