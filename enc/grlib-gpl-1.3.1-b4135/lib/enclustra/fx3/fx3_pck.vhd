library ieee;
use ieee.std_logic_1164.all;
library grlib, techmap;
use grlib.amba.all;
use grlib.amba.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
use techmap.allclkgen.all;
-- use work.config.all;

package fx3_pkg is
  
  type fx3bridge_out is record
    state                 :  std_logic_vector(3 downto 0);
    tohost_fifo_haspacket : std_logic;
    tohost_fifo_isfull    : std_logic;
    cnt                   :  std_logic_vector(31 downto 0);
  end record;


  
  component fx3bridge is
    generic (
      tech         : integer range 0 to NTECH := inferred;
      fragmentsize : integer := 512;
      iflen        : integer := 16);
    port (
      -- clock / reset interface
      Clk_sys			: in	std_logic;
      Clk_fx3			: in	std_logic;
      RESET_N			: in	std_logic;

      dbg_out                   : out fx3bridge_out;
      
      -- sys clock domain:
      avl_data                  : in    std_logic_vector(31 downto 0);
      avl_ready                 : out   std_logic;
      avl_valid                 : in    std_logic;
      avl_endofpacket           : in    std_logic;
      avl_startofpacket         : in    std_logic;
      
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
  end component;

  component fx3fifo is
  generic (
      tech        : integer range 0 to NTECH := inferred;
      iflen       : integer := 16;
      issepclk    : integer := 1;
      abits       : integer := 12;
      packetsz    : integer := (512/4);
      dbits       : integer := 32;
      synbits     : integer := 2   -- at lease 2
  );
  port (    -- clock / reset interface
      Clk_w	  : in std_logic;
      Clk_r       : in std_logic;
      RESET_N	  : in std_logic;
      
      -- read domain:
      fifo_read      : in std_logic;
      fifo_dataout   : out std_logic_vector(dbits-1 downto 0);
      fifo_haspacket : out std_logic;
      fifo_empty     : out std_logic;
      
      -- write domain:
      fifo_write     : in std_logic;
      fifo_datain    : in std_logic_vector(dbits-1 downto 0);
      fifo_isfull    : out std_logic
  );
  end component;
   
  component fx3bridge_apb is
  generic (
      tech        : integer range 0 to NTECH := inferred;
      pindex   : integer := 0;
      paddr    : integer := 0;
      pmask    : integer := 16#fff#;
      pirq     : integer := 0;
      fifosize : integer range 1 to 32 := 1;
      iflen    : integer := 16);
  port (
      rst    : in  std_ulogic;
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
    
      -- clock / reset interface
      Clk_sys			: in	std_logic;
      Clk_fx3			: in	std_logic;
      Clk_fx3_shift		: in	std_logic;
      -- sys clock domain:
      
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
  end component;
  
  

end package;

