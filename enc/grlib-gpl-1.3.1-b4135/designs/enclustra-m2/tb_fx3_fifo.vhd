library ieee;
use ieee.std_logic_1164.all;
library grlib, techmap;
use grlib.amba.all;
use grlib.amba.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
use techmap.allclkgen.all;

library enclustra;
use enclustra.fx3_pkg.all;
use work.config.all;

entity fx3fifo_tb is
  generic (
    clkperiod1   : integer := 10;		-- read system1 clock period
    clkperiod2   : integer := 12;		-- write system2 clock period
    fragmentsize : integer := 214;
    tech        : integer range 0 to NTECH := inferred;
    iflen       : integer := 32;
    issepclk    : integer := 1;
    abits       : integer := 12;
    packetsz    : integer := (512/4);
    synbits     : integer := 2   -- at lease 2
  );
  end;

architecture rtl of fx3fifo_tb is
  
signal clk1     : std_logic := '0';
signal clk2     : std_logic := '0';
constant ct1 : integer := clkperiod1/2;
constant ct2 : integer := clkperiod2/2;
signal rst  : std_ulogic := '0';

constant dbits : integer := iflen;
signal fifo_read      : std_logic;
signal fifo_dataout   : std_logic_vector(dbits-1 downto 0);
signal fifo_haspacket : std_logic;
signal fifo_empty     : std_logic;
      
signal fifo_write     : std_logic;
signal fifo_datain    : std_logic_vector(dbits-1 downto 0);
signal fifo_isfull    : std_logic;

begin

  clk1  <= not clk1 after ct1 * 1 ns;
  clk2  <= not clk2 after ct2 * 1 ns;


  tohost: fx3fifo
  generic map (
      packetsz => fragmentsize,
      dbits => dbits
      )
  port map (
      -- clock / reset interface
      Clk_r       => clk1,
      Clk_w	  => clk2,
      RESET_N	  => rst,
      -- read domain:
      fifo_read      => fifo_read,      
      fifo_dataout   => fifo_dataout,   
      fifo_haspacket => fifo_haspacket, 
      fifo_empty     => fifo_empty,     
      -- write domain:                
      fifo_write     => fifo_write,     
      fifo_datain    => fifo_datain,    
      fifo_isfull    => fifo_isfull    
  );

  rd : process
    variable i : integer := 0;
    variable j : integer := 0;
  begin
    wait for 10 ns;
    wait until rst = '1';
    
    while (i <= 1024*10) loop
      wait until CLK1'event and CLK1='0';
      if fifo_empty = '0' then
        assert ( fifo_dataout = conv_std_logic_vector(i, fifo_dataout'length)) 
          report "*** data mismatch ***"
          severity failure ;
      end if;
      if fifo_haspacket = '1' then
        j := 0;
        while (j <= fragmentsize) loop
          wait until CLK1'event and CLK1='0';
          fifo_read <= '1';
          assert ( fifo_dataout = conv_std_logic_vector(i, fifo_dataout'length)) 
              report "*** data mismatch ***"
              severity failure ;
          j := j + 1;
          i := i + 1;
        end loop; 
        fifo_read <= '0';
      end if;
    end loop; 
    
    
    wait;
  end process;

  wd : process
   variable i : integer := 0;
  begin
    wait for 10 ns;
    wait until rst = '1';

    
    while (i <= 1024*10*2) loop
      wait until CLK2'event and CLK2='0';
      fifo_write <= '0';
      if fifo_isfull = '0' then
         fifo_write <= '1';
         fifo_datain <= conv_std_logic_vector(i, fifo_datain'length);
      end if;
      i := i + 1;
    end loop; 

    
    wait;
  end process;

  rst0 : process
  begin
    rst <= '0';
    wait for 2500 ns;
    rst <= '1';
    wait for 5000 ns;
    wait;
  end process;



  
end;

