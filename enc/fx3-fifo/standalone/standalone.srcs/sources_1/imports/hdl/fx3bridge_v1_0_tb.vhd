library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use work.fx3_pkg.all;

entity fx3bridge_tb is
end fx3bridge_tb;

architecture behavioral of fx3bridge_tb is

  constant ClkPhase_c        : time     := 10 ns;
  signal Clk_50	             : std_logic;
  signal RESET_N             : std_logic; 
  signal data                : std_logic_vector(15 downto 0);
  
  signal FX3_Clk             : std_logic;
  signal FX3_A               : std_logic_vector(1 downto 0);
  signal FX3_DQ_o            : std_logic_vector(16-1 downto 0);
  signal FX3_DQ_i            : std_logic_vector(16-1 downto 0);
  signal FX3_FlagA           : std_logic;
  signal FX3_FlagB           : std_logic;
  signal FX3_SLCS_N          : std_logic;
  signal FX3_SlRd_N          : std_logic;
  signal FX3_SlWr_N          : std_logic;
  signal FX3_SlOe_N          : std_logic;
  signal FX3_Pktend_N        : std_logic;
  signal FX3_SlTri           : std_logic;

  signal FX3_DQ              : std_logic_vector(16-1 downto 0);
  
  constant DATA_WORD         : std_logic_vector(15 downto 0) := (others => '1');
  
begin

  fx3 : process
    variable r: integer;

    variable seed1, seed2: positive;
    variable rand: real;

    procedure rand_int(min : in integer; max : in integer; r: out integer) is
    begin
      uniform(seed1,seed2,rand);
      r := min + integer(real(max-min) * rand) ;			
    end procedure rand_int;

    procedure write_tb(blkcnt: in integer) is
      variable cnt: integer := 0;
      variable lat: integer := 0;
    begin
      while cnt < blkcnt loop
        wait until rising_edge(FX3_Clk);
        
        if FX3_SlRd_N = '0' and FX3_A = 0 then
          if lat < 1 then
            lat := lat + 1;
          else
            cnt := cnt + 1;
            data <= DATA_WORD;
          end if;
        else
          if lat > 0 then
            cnt := cnt + 1;
            lat := lat - 1;
            data <= DATA_WORD;
          else
            lat := 0;
            data <= (others => '0');
          end if;
        end if;
        
        wait for 8 ns;
        if FX3_A = 0 then
          FX3_FLAGA <= '1';
        else
          FX3_FLAGA <= '0';
        end if;
      end loop;
      
      wait until rising_edge(FX3_Clk);
      wait for 8 ns;
      FX3_FLAGA <= '0';
      data <= (others => 'X');
      wait for 1 us;      
    end procedure write_tb;
    
    procedure read_tb(blkcnt: in integer; ok: out boolean) is
      variable cnt: integer := 0;
    begin
      ok := true;
      while cnt < blkcnt loop
        wait until rising_edge(FX3_Clk);
        
        if FX3_SlWr_N = '0' and FX3_A = 2 then
          if FX3_DQ /= DATA_WORD then
            ok := false;
          end if;
          cnt := cnt + 1;
        end if;
        
        wait for 8 ns;	
        
        if FX3_A = 2 and cnt < blkcnt then
          FX3_FLAGB <= '1';
        else
          FX3_FLAGB <= '0';
        end if;
        
      end loop;
      
      wait until rising_edge(FX3_Clk);
      wait for 8 ns;
      FX3_FLAGB <= '0';
      wait for 1 us;			
      
    end procedure read_tb;
    
    variable isok: boolean;
    
  begin
      
    while true loop
      
      rand_int(1,10,r);
      wait for (r * 1 us);
      
      rand_int(0,5,r);
      if 0 < r then
        for i in 0 to r loop
          write_tb(1024);
        end loop;
      end if;
      
      rand_int(0,5,r);
      if 0 < r then
        for i in 0 to r loop
          read_tb(1024, isok);
        end loop;
      end if;
      
    end loop;
    
  end process;

  -----------------------
  oe : process
  begin
    FX3_DQ <= (others => 'Z');	
    wait until RESET_N = '1';
    while true loop
      wait until rising_edge(FX3_Clk);
      wait for 8 ns;
      if FX3_SlOe_N = '0' then
        FX3_DQ <= data;		
      else
        FX3_DQ <= (others => 'Z');			
      end if;
    end loop;
  end process;

  -----------------------
  clk_gen : process
  begin
    RESET_N <= '0';
    wait for 2 us;
    RESET_N <= '1';
    while true loop
      Clk_50 <= '1';
      wait for ClkPhase_c;
      Clk_50 <= '0';
      wait for ClkPhase_c;
    end loop;
    wait;
  end process clk_gen;

end behavioral;

