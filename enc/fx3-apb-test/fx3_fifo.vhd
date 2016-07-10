library ieee;
use ieee.std_logic_1164.all;
library grlib, techmap;
use grlib.amba.all;
use grlib.amba.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
use techmap.allclkgen.all;
-- use work.config.all;

entity fx3fifo is
  generic (
    tech        : integer range 0 to NTECH := inferred;
    iflen       : integer := 32;
    issepclk    : integer := 1;
    abits       : integer := 12;
    packetsz    : integer := (512/4);
    dbits       : integer := 32;
    synbits     : integer := 2   -- at lease 2
  );
  port (    -- clock / reset interface
	    Clk_w	     : in std_logic;
	    Clk_r            : in std_logic;
	    RESET_N	     : in std_logic;
            
            -- read domain:
            fifo_read        : in std_logic;
            fifo_dataout     : out std_logic_vector(dbits-1 downto 0);
            fifo_haspacket   : out std_logic;
            fifo_empty       : out std_logic;
            
            -- write domain:
            fifo_write       : in std_logic;
            fifo_datain      : in std_logic_vector(dbits-1 downto 0);
            fifo_isfull      : out std_logic
            );
  end;

architecture rtl of fx3fifo is
  
type regs_w is record
  wcnt          : std_logic_vector(abits-1 downto 0);
  full          : std_logic;

  wcnt_sync     : std_logic_vector(abits-1 downto 0);
  full_sync     : std_logic;
  rcnt          : std_logic_vector(abits-1 downto 0);
  to_read       : std_logic;
  from_read     : std_logic_vector(synbits-1 downto 0);
end record;

type regs_r is record
  rcnt          :  std_logic_vector(abits-1 downto 0);
  empty         :  std_logic;
  haspacket     :  std_logic;

  rcnt_sync     :  std_logic_vector(abits-1 downto 0);
  wcnt          :  std_logic_vector(abits-1 downto 0);
  full          :  std_logic;
  to_write      :  std_logic;
  from_write    :  std_logic_vector(synbits-1 downto 0);
end record;

signal rw, rwin     : regs_w;
signal rr, rrin     : regs_r;
signal rst : std_logic;
signal fifo_renable_sig : std_logic;
signal fifo_raddress    : std_logic_vector(abits-1 downto 0);

begin
  
  rst <= RESET_N;
  
  ---------------------------------
  -- write clock domain -----------
  ---------------------------------
  
  w : process(rst, rw, rr, fifo_write, fifo_datain )
  variable vw : regs_w;
  begin
    
    vw := rw;

    -- receive read-cnt from read domain
    vw.from_read := rr.to_write & vw.from_read(synbits-1 downto 1);
    if rw.from_read(0) /= vw.from_read(0) then
      vw.rcnt := rr.rcnt_sync;
    end if;
    if (fifo_write and (not rw.full)) = '1' then
      vw.wcnt := rw.wcnt + 1;
      if vw.rcnt = vw.wcnt then
        vw.full := '1';
      end if;
    end if;
    if (rw.full = '1') and (vw.rcnt /= vw.wcnt) then
      vw.full := '0';
    end if;   
    -- send write-cnt to read domain
    if rr.from_write(0) = rw.to_read then
      vw.to_read := not rw.to_read;
      vw.wcnt_sync := vw.wcnt;
      vw.full_sync := vw.full;
    end if;
      
    if (rst = '0') then
      vw.wcnt := (others => '0'); vw.wcnt_sync := (others => '0');
      vw.rcnt := (others => '0'); vw.full_sync := '0';
      vw.to_read := '0';
      vw.full := '0';
    end if;
    
    rwin <= vw;

  end process;

  fifo_isfull <= rw.full;
  
  ----------------------------
  -- read clock domain -------
  ----------------------------
  
  r : process(rst, rr, rw, fifo_read )
  variable vr : regs_r;
  variable sum : std_logic_vector(abits-1+1 downto 0);
  variable filllevel : std_logic_vector(abits-1 downto 0);
  begin

    vr := rr;
    
    -- receive write-cnt from write domain
    vr.from_write := rw.to_read & vr.from_write(synbits-1 downto 1); 
    if rr.from_write(0) /= vr.from_write(0) then
      vr.wcnt := rw.wcnt_sync;
      vr.full := rw.full_sync;
    end if;

    vr.empty := '0';
    if (fifo_read = '1') and ((vr.full = '1') or (vr.rcnt /= vr.wcnt)) then
      vr.rcnt := rr.rcnt + 1;
    end if;
    vr.empty := '0';
    if (vr.full = '0') and (vr.rcnt = vr.wcnt) then
      vr.empty := '1';
    end if;
    
    sum := (vr.wcnt & '1') + ((not vr.rcnt) & '1'); -- (wcnt - rcnt) % circ
    filllevel := sum(abits downto 1);
    vr.haspacket := '0';
    if (vr.full = '1') or  (filllevel >= conv_std_logic_vector(packetsz, filllevel'length)) then
       vr.haspacket := '1';
    end if;
    
    -- send read-cnt to write domain
    if rw.from_read(0) = rr.to_write then
      vr.to_write := not rr.to_write;
      vr.rcnt_sync := vr.rcnt;
    end if;

    if (rst = '0') then
      vr.rcnt := (others => '0');
      vr.wcnt := (others => '0');
      vr.rcnt_sync := (others => '0');
      vr.to_write := '0';
      vr.full := '0';
    end if;

    rrin <= vr;

    fifo_raddress <= vr.rcnt;
      
  end process;

  fifo_empty  <= rr.empty;
  fifo_isfull <= rw.full;
  fifo_haspacket <= rr.haspacket;
  
  ----------------------------------
  -- generate registers ------------
  ----------------------------------
  regsw : process(Clk_w)
  begin
    if rising_edge(Clk_w) then
      rw <= rwin;
    end if;
  end process;
  
  regsr : process(Clk_r)
  begin
    if rising_edge(Clk_r) then
      rr <= rrin;
    end if;
  end process;
  
  fifo : syncram_2p
      generic map (
        tech     => tech,
        abits    => abits,
        dbits    => dbits,
        sepclk   => issepclk,
        wrfst    => 0,
        testen   => 0)
      port map (
        rclk     => Clk_r,
        renable  => fifo_renable_sig,
        raddress => fifo_raddress,
        dataout  => fifo_dataout,
        wclk     => Clk_w,
        write    => fifo_write,
        waddress => rw.wcnt,
        datain   => fifo_datain);

  fifo_renable_sig <= '1';
  
end;

