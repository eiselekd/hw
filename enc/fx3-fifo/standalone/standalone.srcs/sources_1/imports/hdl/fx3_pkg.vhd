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
		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32;

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
        FX3_100mhz          : in std_logic;

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
    end component fx3bridge;

    component fifo_generator_0 IS
    PORT (
      m_aclk : IN STD_LOGIC;
      s_aclk : IN STD_LOGIC;
      s_aresetn : IN STD_LOGIC;
      
      s_axis_tvalid : IN STD_LOGIC;
      s_axis_tready : OUT STD_LOGIC;
      s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axis_tlast : IN STD_LOGIC;
      
      m_axis_tvalid : OUT STD_LOGIC;
      m_axis_tready : IN STD_LOGIC;
      m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axis_tlast : OUT STD_LOGIC
      
      );
    END component fifo_generator_0;     

  

  
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
