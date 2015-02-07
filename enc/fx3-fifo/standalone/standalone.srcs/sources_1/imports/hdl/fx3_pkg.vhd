library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fx3_pkg is
  
  type fx3bridge_out is record
    state                 : std_logic_vector(3 downto 0);
    tohost_fifo_haspacket : std_logic;
    tohost_fifo_isfull    : std_logic;
    cnt                   : std_logic_vector(31 downto 0);
   end record;

  component fx3bridge is
    generic (
      CONST_PATTERN         : integer := 0
      );   
    port (
      av_clk			: in	std_logic;
      av_reset			: in	std_logic; 
      fx3_clk100mhz_in            : in	std_logic; 
      fx3_clk100mhz_270deg_in     : in	std_logic;
      
      -- sys clock domain:
      sink_data                   : in    std_logic_vector(31 downto 0);
      sink_ready                  : out   std_logic;
      sink_valid                  : in    std_logic;
      sink_endofpacket            : in    std_logic;
      sink_startofpacket          : in    std_logic;
      
      -- fx3 clock domain: EZ-USB FX3 slave FIFO interface
      FX3_Clk			: out	std_logic;
      FX3_SLCS_N			: out	std_logic;  -- chip sel
      FX3_SlRd_N			: out	std_logic;
      FX3_SlWr_N			: out	std_logic;
      FX3_SlOe_N                  : out	std_logic;  -- tristate FX3 
      FX3_Pktend_N		: out	std_logic;
      FX3_A			: out	std_logic_vector(1 downto 0);
      FX3_SlTri_N                 : out	std_logic;  -- tristate for DataIn/Out Pad
      FX3_DQ_o			: out	std_logic_vector(31 downto 0);
      FX3_DQ_i			: in	std_logic_vector(31 downto 0);
      FX3_FlagA			: in	std_logic;
      FX3_FlagB			: in	std_logic;
      
      -- dbg output
      FX3DBG_clk                   : out std_logic;
      FX3DBG_state                 : out std_logic_vector(3 downto 0);
      FX3DBG_tohost_fifo_haspacket : out std_logic;
      FX3DBG_tohost_fifo_isfull    : out std_logic;
      FX3DBG_cnt                   : out std_logic_vector(31 downto 0)
  );
  end component;

  component fx3fifo is
    port (    -- clock / reset interface
      Clk_w	  : in std_logic;
      Clk_r       : in std_logic;
      RESET_N	  : in std_logic;
      
      -- read domain:
      fifo_read      : in std_logic;
      fifo_dataout   : out std_logic_vector(31 downto 0);
      fifo_haspacket : out std_logic;
      fifo_empty     : out std_logic;
      
      -- write domain:
      fifo_write     : in std_logic;
      fifo_datain    : in std_logic_vector(31 downto 0);
      fifo_isfull    : out std_logic
    );
  end component;
   
  component dpram0 IS
    PORT
      (
        data            : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        rdaddress       : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
        rdclock         : IN STD_LOGIC ;
        wraddress       : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
        wrclock         : IN STD_LOGIC  := '1';
        wren            : IN STD_LOGIC  := '0';
        q               : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
  END component;
  
  component fx3clk0 IS
    PORT
      (
        areset          : IN STD_LOGIC  := '0';
        inclk0          : IN STD_LOGIC  := '0';
        c0              : OUT STD_LOGIC ;
        c1              : OUT STD_LOGIC ;
        locked          : OUT STD_LOGIC 
      );
  end component;

  component fx3clk1_0002 is
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		outclk_1 : out std_logic;        -- outclk1.clk
		locked   : out std_logic         --  locked.export
	);
   end component;

  
function "+" (d : std_logic_vector; i : integer) return std_logic_vector;
function "+" (a, b : std_logic_vector) return std_logic_vector;
function notx(d : std_logic_vector) return boolean;
function conv_std_logic_vector(i : integer; w : integer) return std_logic_vector;

end package;


package body fx3_pkg is

function notx(d : std_logic_vector) return boolean is
variable res : boolean;
begin
  res := true;
-- pragma translate_off
  res := not is_x(d);
-- pragma translate_on
  return (res);
end;

function "+" (d : std_logic_vector; i : integer) return std_logic_vector is
variable x : std_logic_vector(d'length-1 downto 0);
begin
-- pragma translate_off
  if notx(d) then
-- pragma translate_on
    return(std_logic_vector(unsigned(d) + i));
-- pragma translate_off
  else x := (others =>'X'); return(x);
  end if;
-- pragma translate_on
end;

function conv_std_logic_vector(i : integer; w : integer) return std_logic_vector is
variable tmp : std_logic_vector(w-1 downto 0);
begin
  tmp := std_logic_vector(to_unsigned(i, w));
  return(tmp);
end;

function "+" (a, b : std_logic_vector) return std_logic_vector is
variable x : std_logic_vector(a'length-1 downto 0);
variable y : std_logic_vector(b'length-1 downto 0);
begin
-- pragma translate_off
  if notx(a&b) then
-- pragma translate_on
    return(std_logic_vector(unsigned(a) + unsigned(b)));
-- pragma translate_off
  else
     x := (others =>'X'); y := (others =>'X');
     if (x'length > y'length) then return(x); else return(y); end if;
  end if;
-- pragma translate_on
end;

function ">=" (a, b : std_logic_vector) return boolean is
begin
  return(unsigned(a) >= unsigned(b));
end;


end;
