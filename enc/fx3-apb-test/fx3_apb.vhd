library ieee;
use ieee.std_logic_1164.all;
library grlib, techmap;
use grlib.amba.all;
use grlib.amba.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
use techmap.allclkgen.all;
-- use work.config.all;
library work;
use work.fx3_pkg.all;

entity fx3bridge_apb is
  
  generic (
      tech     : integer range 0 to NTECH := inferred;
      pindex   : integer := 0;
      paddr    : integer := 0;
      pmask    : integer := 16#fff#;
      pirq     : integer := 0;
      abits    : integer := 8;
      fifosize : integer range 1 to 32 := 1;
      iflen    : integer := 16);
  
  port (
      rst    : in  std_ulogic;
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
    
      -- clock / reset interface
      Clk_sys			: in	std_logic;
      Clk_fx3			: in	std_logic;
      Clk_fx3_shift	       	: in	std_logic;
      
      -- fx3 clock domain: EZ-USB FX3 slave FIFO interface
      FX3_SlRd_N		: out	std_logic;
      FX3_SlWr_N		: out	std_logic;
      FX3_SlOe_N		: out	std_logic;
      FX3_SlTri_N		: out	std_logic;
      FX3_Pktend_N		: out	std_logic;
      FX3_A1			: out	std_logic;
      FX3_DQ_o			: out	std_logic_vector(iflen-1 downto 0);
      FX3_DQ_i			: in	std_logic_vector(iflen-1 downto 0);
      FX3_FlagA			: in	std_logic;
      FX3_FlagB			: in	std_logic
  );
  end;

architecture rtl of fx3bridge_apb is
constant REVISION : integer := 1;
constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( 8, 1, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask));

type fx3apb_states is (idle, do_write);

type fx3regs_sys is record
  rcnt          :  std_logic_vector(log2x(fifosize) downto 0);
  tcnt          :  std_logic_vector(log2x(fifosize) downto 0);
  txclk         :  std_logic_vector(2 downto 0);  -- tx clock divider
  rxclk         :  std_logic_vector(2 downto 0);  -- rx clock divider
  
  state         :  fx3apb_states;
  enable        :  std_logic;
  psz           :  std_logic_vector(31 downto 0);
  pcnt          :  std_logic_vector(31 downto 0);
  idx           :  std_logic_vector(31 downto 0);
  pidx          :  std_logic_vector(31 downto 0);

  avl_valid         : std_logic;
  avl_endofpacket   : std_logic;  
  avl_startofpacket : std_logic;
  
end record;

signal r, rin     : fx3regs_sys;

signal avl_data                    : std_logic_vector(31 downto 0);
signal avl_ready                   : std_logic;
signal avl_valid                   : std_logic;
signal avl_endofpacket             : std_logic;
signal avl_startofpacket           : std_logic;

signal dbg_out : fx3bridge_out;

begin

  sys : process(rst, r, apbi )
  variable rxclk, txclk : std_logic_vector(2 downto 0);
  variable rdata : std_logic_vector(31 downto 0);
  variable irq : std_logic_vector(NAHBIRQ-1 downto 0);
  variable paddress : std_logic_vector(7 downto 2);
  variable v : fx3regs_sys;
  variable last  : std_logic_vector(31 downto 0);
  variable first : std_logic_vector(31 downto 0);

  begin

    v := r; irq := (others => '0');
    rdata := (others => '0');
    paddress := (others => '0');
    paddress(abits-1 downto 2) := apbi.paddr(abits-1 downto 2);
    last := r.psz - 1 ;
    first := (others => '0');
    
    -- read registers
    if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
      case paddress(7 downto 2) is
        when "000000" =>
          rdata(0) := r.enable;
          rdata(1) := r.avl_valid;
          rdata(2) := avl_ready;
        when "000001" => -- 4
          rdata := r.psz;
        when "000010" => -- 8
          rdata := r.pcnt;
        when "000011" => -- c
          rdata := r.idx;
        when "000100" => -- 0x10
          rdata := r.pidx;
        when "000101" => -- 0x14
          rdata(3 downto 0) := dbg_out.state;
          rdata(4) := dbg_out.tohost_fifo_haspacket;
          rdata(5) := dbg_out.tohost_fifo_isfull;
        when "000110" => -- 0x18
          rdata := dbg_out.cnt;
        when others =>
          null;
      end case;
    end if;
    
    -- write registers
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case paddress(7 downto 2) is
        when "000000" =>
          v.state := do_write;
          v.enable := '1'; v.avl_valid := '1';
          v.idx := (others => '0');
          v.pidx := (others => '0');
          if apbi.pwdata(1) = '1' then
            v.psz  := conv_std_logic_vector(1024, 32);
            v.pcnt := conv_std_logic_vector(1024*1024*1024, 32);
          end if;
        when "000001" =>
          v.psz := apbi.pwdata;
        when "000010" =>
          v.pcnt := apbi.pwdata;
        when "000011" =>
          
        when "000100" =>
          
        when others =>
          null;
      end case;
    end if;

    case r.state is
      when idle=> null;
      when do_write=>
        if (r.avl_valid and avl_ready) = '1' then
          v.idx := v.idx + 1;
        end if;
        if v.idx = v.psz then
          v.pidx := v.pidx + 1;
          v.idx := (others => '0');
          if v.pidx = v.pcnt then
            v.idx := (others => '0');
            v.pidx := (others => '0');
            v.state := idle;
            v.enable := '0';
            v.avl_valid := '0';
          end if;
        end if; 
    end case ;
    
    v.avl_startofpacket := '0';
    v.avl_endofpacket := '0';
    if v.idx = last then
      v.avl_endofpacket := '1';
    end if;
    if v.idx = first then
      v.avl_startofpacket := '1';
    end if;
    
    -- reset operation
    if (rst = '0') then
      --v.enable := '0';
      --v.state := idle;
      v.rcnt := (others => '0'); v.tcnt := (others => '0');
      v.rxclk := (others => '0'); v.txclk := (others => '0');
      
      v.state := do_write;
      v.enable := '1'; v.avl_valid := '1';
      v.psz  := conv_std_logic_vector(1024, 32);
      v.pcnt := conv_std_logic_vector(1024*1024*1024, 32);
      v.idx := (others => '0');
      v.pidx := (others => '0');
    end if;

    -- update registers
    rin <= v;

    -- drive outputs
    apbo.prdata <= rdata; apbo.pirq <= irq;
    apbo.pindex <= pindex;


    
  end process;

  avl_valid         <= r.avl_valid;
  avl_data          <= r.idx;
  avl_endofpacket   <= r.avl_endofpacket;
  avl_startofpacket <= r.avl_startofpacket;
  
  apbo.pconfig <= pconfig;
  
  regs : process(Clk_sys)
  begin
    if rising_edge(Clk_sys) then
      r <= rin;
    end if;
  end process;

  fxb: fx3bridge
    generic map (
      tech => tech,
      iflen => iflen)
    port map (
      Clk_sys		=> Clk_sys,
      Clk_fx3		=> Clk_fx3,			
      RESET_N		=> rst,

      dbg_out           => dbg_out,
      
      -- sys clock domain:
      avl_data          => avl_data,         
      avl_ready         => avl_ready,        
      avl_valid         => avl_valid,        
      avl_endofpacket   => avl_endofpacket,  
      avl_startofpacket => avl_startofpacket,
      
      -- fx3 clock domain: EZ-USB FX3 slave FIFO interface
      FX3_SlRd_N	=> FX3_SlRd_N,		
      FX3_SlWr_N	=> FX3_SlWr_N,		
      FX3_SlOe_N	=> FX3_SlOe_N,		
      FX3_SlTri_N	=> FX3_SlTri_N,
      FX3_Pktend_N	=> FX3_Pktend_N,		
      FX3_A1		=> FX3_A1,			
      FX3_DQ_o		=> FX3_DQ_o,			
      FX3_DQ_i		=> FX3_DQ_i,			
      FX3_FlagA		=> FX3_FlagA,		
      FX3_FlagB		=> FX3_FlagB		
  );
  
-- pragma translate_off
    bootmsg : report_version
    generic map ("FX3" & tost(pindex) &
        ": FX3 apb rev " & tost(REVISION) & ", fifo " & tost(fifosize) );
-- pragma translate_on


end;

