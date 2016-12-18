-----------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2011 Jiri Gaisler, Gaisler Research
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
library grlib, techmap;
use grlib.amba.all;
use grlib.amba.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
use techmap.allclkgen.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.spi.all;
use gaisler.i2c.all;
use gaisler.can.all;
use gaisler.net.all;
use gaisler.jtag.all;
use gaisler.spacewire.all;
library enclustra;
use enclustra.fx3_pkg.all;
-- pragma translate_off
use gaisler.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on



library esa;
use esa.memoryctrl.all;

use work.config.all;

entity leon3mp is
  generic (
    fabtech       : integer := CFG_FABTECH;
    memtech       : integer := CFG_MEMTECH;
    padtech       : integer := CFG_PADTECH;
    clktech       : integer := CFG_CLKTECH;
    disas         : integer := CFG_DISAS;   -- Enable disassembly to console
    dbguart       : integer := CFG_DUART;   -- Print UART on console
    pclow         : integer := CFG_PCLOW;
    iflen         : integer := 32
  );
  port (

		-- clock / reset interface
		Clk_50				: in	std_logic;
		
		RESET_N				: in	std_logic; 

		-- EZ-USB FX3 slave FIFO interface
		FX3_Clk				: out	std_logic;
		FX3_SlRd_N			: out	std_logic;
		FX3_SlWr_N			: out	std_logic;
		FX3_SlOe_N			: out	std_logic;
		FX3_Pktend_N		        : out	std_logic;
		FX3_A1				: out	std_logic;
		FX3_DQ				: inout	std_logic_vector(iflen-1 downto 0);
		FX3_FlagA			: in	std_logic;
		FX3_FlagB			: in	std_logic;
		
		-- Ethernet interface
		Eth_Rst_N			: out	std_logic;
		
		-- I2C interface
		I2c_Int_N			: inout	std_logic;
		I2c_Scl				: inout	std_logic;
		I2c_Sda				: inout	std_logic;
	
		-- SPI Flash interface
		Flash_Clk			: inout	std_logic;
		Flash_Cs_N			: inout	std_logic;
		Flash_Do			: inout	std_logic;
		Flash_Di			: inout	std_logic;
		Flash_Hold_N	     	        : inout	std_logic;
		Flash_Wp_N			: inout	std_logic;

 -- pragma translate_off
    -- UART
                
    txd1        : out std_ulogic;           -- UART1 tx data
    rxd1        : in  std_ulogic;           -- UART1 rx data
    ctsn1       : in  std_ulogic;           -- UART1 ctsn
    rtsn1       : out std_ulogic;           -- UART1 trsn
    txd2        : out std_ulogic;           -- UART2 tx data
    rxd2        : in  std_ulogic;           -- UART2 rx data
    ctsn2       : in  std_ulogic;           -- UART2 ctsn
    rtsn2       : out std_ulogic;           -- UART2 rtsn
                
 -- pragma translate_on
                
		-- Led interface
		Led_N				: out	std_logic_vector (3 downto 0)

                

   );
end;

architecture rtl of leon3mp is

--components clk_gen
component clk_wiz_v3_6_2
	port(
	     CLK_IN1	: in std_logic;
	     CLK_OUT1   : out std_logic;
	     CLK_OUT2   : out std_logic;
	     RESET      : in std_logic;
	     LOCKED	: out std_logic);
end component;

component BUFG port (O : out std_logic; I : in std_logic); end component;

component IODELAY2
  generic (
     COUNTER_WRAPAROUND : string := "WRAPAROUND";
     DATA_RATE : string := "SDR";
     DELAY_SRC : string := "IO";
     IDELAY2_VALUE : integer := 0;
     IDELAY_MODE : string := "NORMAL";
     IDELAY_TYPE : string := "DEFAULT";
     IDELAY_VALUE : integer := 0;
     ODELAY_VALUE : integer := 0;
     SERDES_MODE : string := "NONE";
     SIM_TAPDELAY_VALUE : integer := 75
  );
  port (
     BUSY : out std_ulogic;
     DATAOUT : out std_ulogic;
     DATAOUT2 : out std_ulogic;
     DOUT : out std_ulogic;
     TOUT : out std_ulogic;
     CAL : in std_ulogic;
     CE : in std_ulogic;
     CLK : in std_ulogic;
     IDATAIN : in std_ulogic;
     INC : in std_ulogic;
     IOCLK0 : in std_ulogic;
     IOCLK1 : in std_ulogic;
     ODATAIN : in std_ulogic;
     RST : in std_ulogic;
     T : in std_ulogic
  );
end component;
  component ODDR2
  generic
  (
    DDR_ALIGNMENT : string := "NONE";
    INIT : bit := '0';
    SRTYPE : string := "ASYNC"
  );
  port
  (
    Q : out std_ulogic;
    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D0 : in std_ulogic;
    D1 : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic
  );
  end component;
  
attribute syn_netlist_hierarchy : boolean;
attribute syn_netlist_hierarchy of rtl : architecture is false;

constant use_eth_input_delay : integer := 1;
constant use_eth_output_delay : integer := 1;

constant blength : integer := 12;
constant fifodepth : integer := 8;

constant in_simulation : integer := 0
--pragma synthesis_off
                                    + 1
--pragma synthesis_on
;
constant in_synthesis : integer := (in_simulation + 1) mod 2;
  
constant maxahbm : integer := 1+1+in_simulation; -- cpu, dsu, ahbuart(if sim)

signal FX3_SlRd_N_sig			: std_logic;
signal FX3_SlWr_N_sig			: std_logic;
signal FX3_SlOe_N_sig			: std_logic;
signal FX3_SlOe_pad_n                   : std_logic;
signal FX3_A1_sig                       : std_logic;
signal FX3_Pktend_N_sig		        : std_logic;
signal FX3_DQ_sig			: std_logic_vector(iflen-1 downto 0);
signal FX3_DQ_i				: std_logic_vector(iflen-1 downto 0);
signal FX3_DQ_o				: std_logic_vector(iflen-1 downto 0);

signal vcc, gnd   : std_logic;
signal memi  : memory_in_type;
signal memo  : memory_out_type;
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo   : sdram_out_type;
signal leds  : std_logic_vector(3 downto 0);    -- I/O port

signal apbi, apbi2  : apb_slv_in_type;
signal apbo, apbo2  : apb_slv_out_vector := (others => apb_none);
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
signal ahbmi : ahb_mst_in_type;
signal vahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);
signal vahbmo : ahb_mst_out_type;

signal clkm, rstn, rstraw, sdclkl : std_ulogic;
signal clk_200 : std_ulogic;
signal clk25, clk40, clk65 : std_ulogic;

  signal i2ci : i2c_in_type;
  signal i2co : i2c_out_type;

signal cgi, cgi2, cgi3   : clkgen_in_type;
signal cgo, cgo2, cgo3   : clkgen_out_type;
signal u1i, u2i, dui : uart_in_type;
signal u1o, u2o, duo : uart_out_type;

signal irqi : irq_in_vector(0 to CFG_NCPU-1);
signal irqo : irq_out_vector(0 to CFG_NCPU-1);

signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

signal dsui : dsu_in_type;
signal dsuo : dsu_out_type;

signal gmiii, rgmiii, rgmiii_buf : eth_in_type;
signal gmiio, rgmiio : eth_out_type;

signal gpti : gptimer_in_type;
signal gpto : gptimer_out_type;

signal gpioi : gpio_in_type;
signal gpioo : gpio_out_type;

signal gpioi2 : gpio_in_type;
signal gpioo2 : gpio_out_type;

signal gpioi3 : gpio_in_type;
signal gpioo3 : gpio_out_type;

signal can_lrx, can_ltx   : std_logic_vector(0 to 7);

signal lockpll, calib_done, clkml, lclk, rst, ndsuact, wdogl : std_ulogic := '0';
signal tck, tckn, tms, tdi, tdo : std_ulogic;
constant OEPOL : integer := padoen_polarity(padtech);

--signal ethclk, ddr2clk : std_ulogic;

constant BOARD_FREQ : integer := 50000;   -- input frequency in KHz
constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz
constant IOAEN : integer := CFG_CAN;

signal stati : ahbstat_in_type;

signal fpi : grfpu_in_vector_type;
signal fpo : grfpu_out_vector_type;

signal rstgtxn          : std_logic;
signal idelay_reset_cnt : std_logic_vector(3 downto 0);
signal idelay_cal_cnt   : std_logic_vector(3 downto 0);
signal idelayctrl_reset : std_logic;
signal idelayctrl_cal   : std_logic;

--signal clk         : std_ulogic;
constant SPW_LOOP_BACK : integer := 0;

signal clk50, clk100, spw100 : std_logic;  -- signals to vga_clkgen.
signal clk_sel : std_logic_vector(1 downto 0);
signal clkvga, clkvga_p, clkvga_n : std_ulogic;
signal clk_125 : std_ulogic;
signal nerror : std_ulogic;

signal clk_100			      : std_logic;
signal clk_100_shift                  : std_logic;
signal clk_100_shift_n                : std_logic;
signal clk_100_n		      : std_logic;
signal clk_100_180		      : std_logic;
signal reset2pll                : std_logic;
signal clklocks                : std_logic;
signal FX3_Clk_gen : std_logic;

type regs_sys is record
  cnt_led : std_logic_vector(32 downto 0);
end record;
signal rsys, rsysin     : regs_sys;
  
attribute keep : boolean;
attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of clk50 : signal is true;
attribute syn_preserve of clk50 : signal is true;
attribute keep of clk50 : signal is true;
attribute syn_preserve of clkm : signal is true;
attribute keep of clkm : signal is true;


begin


  -- Led_N(0) <=         '0'; -- dsuact
  -- Led_N(1) <= '1'; -- errno
  
  --led_n(0) <= FX3_SlWr_N_sig;
  --led_n(1) <= FX3_A1_sig;
  --led_n(2) <= FX3_FlagA;
  --led_n(3) <= FX3_FlagB;

  led_n(0) <= rsys.cnt(10);
  led_n(1) <= rsys.cnt(10);
  led_n(2) <= rsys.cnt(10);
  led_n(3) <= rsys.cnt(10);

  
----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc <= '1'; gnd <= '0';
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw;

  clk_pad : clkpad generic map (tech => padtech) port map (clk_50, lclk);

  clkgen0 : clkgen        -- clock generator
    generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, CFG_MCTRL_SDEN,
   CFG_CLK_NOFB, 0, 0, 0, BOARD_FREQ)
    port map (lclk, lclk, clkm, open, open, sdclkl, open, cgi, cgo, open, clk50, clk100);

  clklocks <= lockpll; -- and cgo.clklock (no sdram) 
  rst0 : rstgen         -- reset generator
   port map (rst, clkm, clklocks, rstn, rstraw);

  resetn_pad : inpad generic map (tech => padtech) port map (reset_n, rst);

  --generating the clock(PLL instantiation)
  reset2pll <= not rst;
  inst_clk : clk_wiz_v3_6_2
	port map (
                CLK_IN1	      => lclk,
	        CLK_OUT1      => clk_100,
                CLK_OUT2      => clk_100_shift,
		RESET         => reset2pll,
                LOCKED	      => lockpll);
  
  --ODDR2 instantiation to send the clk to FX3
  clk_100_n <= not clk_100;
  clk_100_shift_n <= not clk_100_shift;
  FX3_Clk <= FX3_Clk_gen;
  oddr_inst : ODDR2                       
	port map (   
	  	D0     => '1',                
	        D1     => '0',
	        C0     => clk_100_shift, --clk_100,
	        C1     => clk_100_shift_n, --clk_100_n,
	        Q      => FX3_Clk_gen, -- clk_out
		CE     => '1',
		S      => '0', --open,
		R      => '0'  --open
		);      

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl       -- AHB arbiter/multiplexer
  generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
   rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
   nahbm => maxahbm, nahbs => 3)
  port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  nosh : if CFG_LEON3 > 0 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
      l3s : if CFG_LEON3FT_EN = 0 generate
        u0 : leon3s 		-- LEON3 processor
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU*(1-CFG_GRFPUSH), CFG_V8,
	  0, CFG_MAC, pclow, CFG_NOTAG, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
	  CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	  CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
          CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
          CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1,
	  CFG_DFIXED, CFG_SCAN, CFG_MMU_PAGE, CFG_BP)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso,
    		irqi(i), irqo(i), dbgi(i), dbgo(i));
      end generate;
    end generate;
  end generate;
  
  noleon : if CFG_LEON3 = 0 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
      ahbmo(i) <= ahbm_none;
    end generate;
  end generate;
  
  nerror <= dbgo(0).error;
  --led1_pad : odpad generic map (tech => padtech) port map (led_n(1), nerror);

  dsu0 : dsu3         -- LEON3 Debug Support Unit
      generic map (hindex => 1, haddr => 16#900#, hmask => 16#F00#,
         ncpu => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clkm, ahbmi, ahbsi, ahbso(1), dbgo, dbgi, dsui, dsuo);
      dsui.enable <= '1';
      dsui.break <= '1';
      --dsuen_pad : inpad generic map (tech => padtech) port map (switch(7), dsui.enable);
      --dsubre_pad : inpad generic map (tech => padtech) port map (switch(8), dsui.break);
      --dsuact_pad : outpad generic map (tech => padtech) port map (led_n(0), ndsuact);
      ndsuact <= not dsuo.active;


  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU),
               open, open, open, open, open, open, open, gnd);
  end generate;

  -- pragma translate_off
    dcom0: ahbuart      -- Debug UART
      generic map (hindex => CFG_NCPU+CFG_AHB_JTAG, pindex => 4, paddr => 4)
      port map (rstn, clkm, dui, duo, apbi, apbo(4), ahbmi, ahbmo(CFG_NCPU+CFG_AHB_JTAG));
      dsurx_pad : inpad generic map (tech => padtech) port map (rxd2, dui.rxd);
      dsutx_pad : outpad generic map (tech => padtech) port map (txd2, duo.txd);
  -- pragma translate_on
    uls: if in_synthesis = 1 generate
      apbo(4) <= apb_none; 
    end generate;
  
-----------------------------------------------------------------------
---  Test report module  ----------------------------------------------
-----------------------------------------------------------------------

 -- pragma translate_off
 
 -- test0 : ahbrep generic map (hindex => 6, haddr => 16#200#)
 --	port map (rstn, clkm, ahbsi, ahbso(3));

 -- pragma translate_on

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl            -- AHB/APB bridge
  generic map (hindex => 0, haddr => CFG_APBADDR, nslaves => 16)
  port map (rstn, clkm, ahbsi, ahbso(0), apbi, apbo );

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart         -- UART 1
    generic map (pindex => 1, paddr => 1,  pirq => 2, console => dbguart, flow => 0,
   fifosize => CFG_UART1_FIFO)
    port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.extclk <= '0';
    uls: if in_synthesis = 1 generate
      u1i.rxd <= '1';
    end generate;
    ulsim: if in_simulation = 1 generate
 -- pragma translate_off
      rxd1_pad : inpad generic map (tech => padtech) port map (rxd1, u1i.rxd);
      txd1_pad : outpad generic map (tech => padtech) port map (txd1, u1o.txd);
      cts1_pad : inpad generic map (tech => padtech) port map (ctsn1, u1i.ctsn);
      rts1_pad : outpad generic map (tech => padtech) port map (rtsn1, u1o.rtsn);
 -- pragma translate_on
    end generate;
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;
  --rts1_pad : outpad generic map (tech => padtech) port map (rtsn2, '0');

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp         -- interrupt controller
    generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU)
    port map (rstn, clkm, apbi, apbo(2), irqo, irqi);
  end generate;
  
  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer          -- timer unit
    generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ,
   sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM,
   nbits => CFG_GPT_TW, wdog => CFG_GPT_WDOGEN*CFG_GPT_WDOG)
    port map (rstn, clkm, apbi, apbo(3), gpti, gpto);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;
  wden : if CFG_GPT_WDOGEN /= 0 generate
    wdogl <= gpto.wdogn or not rstn;
    --wdogn_pad : odpad generic map (tech => padtech) port map (wdogn, wdogl);
  end generate;


  --i2cm: if CFG_I2C_ENABLE = 1 generate  -- I2C master
  --  i2c0 : i2cmst
  --    generic map (pindex => 6, paddr => 6, pmask => 16#FFF#,
  --                 pirq => 3, filter => 3, dynfilt => 1)
  --    port map (rstn, clkm, apbi, apbo(4), i2ci, i2co);
  --end generate;
  --noi2cm: if CFG_I2C_ENABLE = 0 generate
  --  i2co.scloen <= '1'; i2co.sdaoen <= '1';
  --  i2co.scl <= '0'; i2co.sda <= '0';
  --end generate;
  --i2c_scl_pad : iopad generic map (tech => padtech)
  --  port map (I2c_Scl, i2co.scl, i2co.scloen, i2ci.scl);
  --i2c_sda_pad : iopad generic map (tech => padtech)
  --  port map (I2c_Sda, i2co.sda, i2co.sdaoen, i2ci.sda);
  
  
  --apbo(5) <= apb_none; 
  apbo(6) <= apb_none; 
  apbo(13) <= apb_none;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

    ahbram0 : ahbram generic map (hindex => 2, haddr => CFG_AHBRADDR,
   tech => CFG_MEMTECH, kbytes => CFG_AHBRSZ, pipe => CFG_AHBRPIPE)
    port map ( rstn, clkm, ahbsi, ahbso(2));

 -----------------------------------------------------------------------
 ---  FX3                        ---------------------------------------
 -----------------------------------------------------------------------

  fx3: fx3bridge_apb
    generic map (
      tech => memtech,
      pindex => 5,
      paddr  => 5,
      pirq   => 11,
      fifosize => 32,
      iflen => iflen)
    port map (
      rst   => rstn,
      apbi  => apbi, 
      apbo  => apbo(5),
      
      -- clock / reset interface
      Clk_sys       => clkm,
      Clk_fx3       => clk_100,
      Clk_fx3_shift => FX3_Clk_gen,
      -- sys clock domain:
      
      -- fx3 clock domain: EZ-USB FX3 slave FIFO interface
      FX3_SlRd_N	=> FX3_SlRd_N_sig,		
      FX3_SlWr_N	=> FX3_SlWr_N_sig,		
      FX3_SlOe_N	=> FX3_SlOe_N_sig,
      FX3_SlTri_N       => FX3_SlOe_pad_n,
      FX3_Pktend_N	=> FX3_Pktend_N,		
      FX3_A1		=> FX3_A1_sig,			
      FX3_DQ_o		=> FX3_DQ_o, --_sig,			
      FX3_DQ_i		=> FX3_DQ_i, --_sig,			
      FX3_FlagA		=> FX3_FlagA,		
      FX3_FlagB		=> FX3_FlagB		
  );
  
  data_pad : iopadv generic map (tech => padtech, width => iflen, oepol => oepol)
     port map (FX3_DQ, FX3_DQ_o, FX3_SlOe_pad_n, FX3_DQ_i);

  --FX3_DQ_o <= (others => '0');
  FX3_SlWr_N <= FX3_SlWr_N_sig;
  FX3_SlOe_N <= '1';
  FX3_SlRd_N <= '1';
  FX3_A1 <= FX3_A1_sig;
    
  -- FX3_DQ_o  <= "1000100010001000";

  sys : process(rsys )
  variable vsys : regs_sys;
  begin
    
    vsys := rsys;

    vsys.cnt := vsys.cnt + 1;
    
    rsysin <= vsys;
  end process;

  regssys : process(Clk_50)
  begin
    if rising_edge(Clk_50) then
      rsys <= rsysin;
    end if;
  end process;

  
  --FX3_DQ <= (others =>'Z');
  
 -----------------------------------------------------------------------
 ---  Drive unused bus elements  ---------------------------------------
 -----------------------------------------------------------------------

 --  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG) to NAHBMST-1 generate
 --    ahbmo(i) <= ahbm_none;
 --  end generate;
 --  nap0 : for i in 11 to NAPBSLV-1 generate apbo(i) <= apb_none; end generate;
 -- nah0 : for i in 3 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

 -----------------------------------------------------------------------
 ---  Boot message  ----------------------------------------------------
 -----------------------------------------------------------------------

 -- pragma translate_off
   x : report_design
   generic map (
    msg1 => "LEON3 Enclustra Demonstration design",
    fabtech => tech_table(fabtech), memtech => tech_table(memtech),
    mdel => 1
   );
 -- pragma translate_on
 end;

