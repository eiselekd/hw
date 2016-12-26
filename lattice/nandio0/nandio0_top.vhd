library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.UART.all;
use work.nandio.all;

entity nandio_top is
   port(
      clk_i      : in  std_logic;  -- CPU clock                                                                                 
      rstn       : in  std_logic;  -- Reset                                                                                     
      break_o    : out std_logic;  -- Break executed                                                                            
      rs232_tx_o : out std_logic;  -- UART Tx                                                                                   
      rs232_rx_i : in  std_logic;  -- UART Rx                                                                                   

      -- NAND chip control hardware interface
      nand_cle                          : out   std_logic := '0';
      nand_ale                          : out   std_logic := '0';
      nand_nwe                          : out   std_logic := '1';
      nand_nwp                          : out   std_logic := '0';
      nand_nce                          : out   std_logic := '1';
      nand_nre                          : out   std_logic := '1';
      nand_rnb                          : in    std_logic;
      nand_data                 : inout std_logic_vector(15 downto 0);
      
      -- led interface                                                                                                          
      LED2  : out std_logic;
      LED3  : out std_logic;
      LED4  : out std_logic;
      LED6  : out std_logic;
      LED7  : out std_logic;
      LED8  : out std_logic;
      LED9  : out std_logic

      );
end entity nandio_top;

architecture rtl of nandio_top is

   constant CLK_FREQ   : positive:=12; -- 12 MHz clock
   constant BRATE      : positive:=9600; -- RS232 baudrate
   constant BRDIVISOR  : positive:=CLK_FREQ*1e6/BRATE/4;

   -- UART
   signal rx_read  : std_logic;
   signal rx_avail : std_logic;
   signal rx_data  : std_logic_vector(7 downto 0);
   signal tx_write : std_logic;
   signal tx_busy  : std_logic;
   signal tx_data  : std_logic_vector(7 downto 0);
   
   -- ftdi like commands   
   type nandio_states is (nandio_idle, cmd_wait, cmd, addrwrite, datawrite, dataread_wait, dataread, dowait);
   type regs_nandio is record
      state         : nandio_states;
      cnt           : std_logic_vector(5 downto 0);
      nand_cle      : std_logic_vector(1 downto 0);
      nand_ale      : std_logic_vector(1 downto 0);
      nand_nwe      : std_logic;
      nand_nwp      : std_logic;
      nand_nce      : std_logic;
      nand_nre      : std_logic;
      nand_data_out : std_logic_vector(15 downto 0);
      rx_read       : std_logic;
      tx_write      : std_logic;
      tx_data       : std_logic_vector(7 downto 0);
      rx_data       : std_logic_vector(7 downto 0);
      rx_data_valid : std_logic;
      nand_outen    : std_logic;
      nand_outen_n  : std_logic;
      tx_busy       : std_logic;
   end record;

   signal r, rin   : regs_nandio;
   signal clk, rst, reset_i      : std_logic;
   
begin

  clk <= clk_i;
  rst <= not rstn;
  reset_i <= not rstn;

  sys : process(rst, r, clk, nand_rnb, nand_data, rx_avail, tx_busy, rx_data)
    variable v : regs_nandio;
    variable dowrite : std_logic;
  begin
    v := r;

    dowrite := '0';
    v.tx_busy := tx_busy;
    v.nand_cle := "0" & v.nand_cle(1);
    v.nand_ale := "0" & v.nand_ale(1);
    v.nand_nwe := '1';
    v.nand_nwp := '1';
    v.nand_nce := '0';
    v.nand_nre := '1';
    v.rx_read := '0';
    v.tx_write := '0';
    v.nand_outen_n := '0';
    v.nand_outen := r.nand_outen_n;

    -----------------
    -- ccxx_xxxx :
    -- cc : 00 : cmd write with data:
    --           xx_xxx : 0 : READID: 0x90
    -- cc : 10 : setup address write cycles
    --           xx_xxx : cnt: followed by <cnt> write cycles
    -- cc : 01 : setup data read cycles
    --           xx_xxx : cnt: followed by <cnt> read cycles
    -- cc : 11 : setup data write cycles
    --           xx_xxx : cnt: followed by <cnt> write cycles
    -----------------
    
    case r.state is
      when nandio_idle =>
        if (rx_avail = '1') then
          v.rx_read := '1';
          v.cnt := rx_data(5 downto 0);
          case rx_data(7 downto 6) is
            when "00" =>
              v.state := cmd_wait;
              case rx_data(3 downto 0) is
                when "0000" => v.nand_data_out(7 downto 0) := conv_std_logic_vector(16#90#, 8);
                when "0001" => v.nand_data_out(7 downto 0) := conv_std_logic_vector(16#ff#, 8);
                when others => null;
              end case ;
            when "10" =>
              v.state := addrwrite;
            when "11" =>
              v.state := datawrite;
            when "01" =>
              v.state := dataread_wait;
            when others =>
              null;
          end case;
        end if;

      -- write cycle by sending [nwe] rising edge and cmd latch enable
      when cmd_wait =>
        if (nand_rnb /= '0') then
          v.state := cmd;
        end if;
      when cmd =>
        v.nand_cle := (others => '1');
        v.state := nandio_idle;
        v.nand_outen := '1';
        v.nand_outen_n := '1';
        v.nand_nwe := '0';
                          
      -- do <cnt> write cycles by sending [nwe] rising edge, address latch enabeld
      when addrwrite =>
        v.nand_ale := (others => '1');
        dowrite := '1';
          
      -- do <cnt> write cycles by sending [nwe] rising edge
      when datawrite =>
        dowrite := '1';
          
      -- wait for rnb and end byte reply
      when dowait =>
        if (nand_rnb /= '0' and (r.tx_busy = '0')) then
          v.tx_write := '1';
          v.tx_data := (others => '0');
          v.state := nandio_idle;
        end if;

      -- do <cnt> read cycles by sending [nre] rising edge 
      when dataread_wait =>
        if (nand_rnb /= '0') then
          v.state := dataread;
          v.nand_nre := '0';
        end if;
      when dataread =>
        if r.nand_nre = '0' then
          v.tx_data := nand_data(7 downto 0);
        else
          if (r.tx_busy = '0') then
            v.tx_write := '1';
            v.cnt := r.cnt - 1;
            if (v.cnt = "000000") then
              v.state := nandio_idle;
            else
              v.nand_nre := '0';
            end if;
          end if;
        end if;
      when others =>
        null;    
    end case;

    -- data and address writes
    if (dowrite = '1') then
      if (rx_avail = '1') then
        v.rx_data_valid := '1';
        v.rx_data := rx_data;
        v.rx_read := '1';
      end if;
      if (nand_rnb /= '0' and v.rx_data_valid = '1') then
        v.rx_data_valid := '0';
        v.nand_nwe := '0';
        v.nand_outen := '1';
        v.nand_outen_n := '1';
        v.nand_data_out(7 downto 0) := v.rx_data;
        v.cnt := r.cnt - 1;
        if (v.cnt = "000000") then
          v.state := nandio_idle;
        end if;
      end if;
    end if;

    if (rst = '1') then
      v.state := nandio_idle;
      v.nand_outen := '0';
      v.nand_outen_n := '0';
    end if;
    
    rin <= v;
    nand_cle  <= r.nand_cle(0);
    nand_ale  <= r.nand_ale(0);     
    nand_nwe  <= r.nand_nwe;     
    nand_nwp  <= r.nand_nwp;     
    nand_nce  <= r.nand_nce;     
    nand_nre  <= r.nand_nre;

    rx_read <= v.rx_read;
    tx_write <= r.tx_write;
    tx_data <= r.tx_data;

  end process;

  nand_data <= r.nand_data_out when (r.nand_outen = '1') else (others => 'Z');

  regs : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process;

  u0: uartio 
    port map(
      clk_i => clk,
      rst_i => reset_i,         
      rs232_tx_o => rs232_tx_o,
      rs232_rx_i => rs232_rx_i,             
      -- rx:
      rx_read => rx_read,
      rx_avail => rx_avail,
      rx_data => rx_data,
      -- tx:
      tx_write => tx_write,
      tx_busy => tx_busy,
      tx_data => tx_data
      );            

end architecture rtl;
