library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.UART.all;

entity uartio is
   port(
      clk_i      : in  std_logic;  -- CPU clock                                                                                 
      rst_i      : in  std_logic;  -- Reset                                                                                     
      rs232_tx_o : out std_logic;  -- UART Tx                                                                                   
      rs232_rx_i : in  std_logic;  -- UART Rx                                                                                   
      -- rx:
      rx_read  : in  std_logic;
      rx_avail : out std_logic;
      rx_data  : out std_logic_vector(7 downto 0);
      -- tx:
      tx_write : in std_logic;
      tx_busy  : out std_logic;
      tx_data  : in std_logic_vector(7 downto 0)
      );
end entity uartio;


architecture rtl of uartio is

   constant CLK_FREQ   : positive:=12; -- 50 MHz clock
   constant BRATE      : positive:=9600; -- RS232 baudrate
   constant BRDIVISOR  : positive:=CLK_FREQ*1e6/BRATE/4;

   -- UART
   -- Rx
   signal rx_br      : std_logic; -- Rx timing
   signal uart_read  : std_logic; -- ZPU read the value
   -- Tx
   signal tx_br      : std_logic; -- Tx timing
   signal uart_write : std_logic; -- ZPU is writing
   
   signal br_clk_i   : std_logic;

   -- ftdi like commands   
   type uart_states is (nandio_idle, waitcmd, getmode, writecycles, readcycles
	);
   type uart_regs is record
      state         : uart_states;
      cnt           : std_logic_vector(31 downto 0);
   end record;

   signal r, rin   : uart_regs;
   signal clk, rst, reset_i      : std_logic;

begin

  clk <= clk_i;
  rst <= rst_i;
  reset_i <= rst_i;

  sys : process(rst, r)
  variable v : uart_regs;
  begin
    v := r;
    rin <= v;
  end process;

  regs : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process;

   ----------
   -- UART --
   ----------
   -- Rx section
   rx_core : RxUnit
      port map(
         clk_i => clk, reset_i => reset_i, enable_i => rx_br,
         read_i => uart_read, rxd_i => rs232_rx_i, rxav_o => rx_avail,
         datao_o => rx_data);
   uart_read <= rx_read; -- '1' when re_i='1' and addr_i=UART_RX else '0';

   -- Tx section
   tx_core : TxUnit
      port map(
         clk_i => clk_i, reset_i => reset_i, enable_i => tx_br,
         load_i => uart_write, txd_o => rs232_tx_o, busy_o => tx_busy,
         datai_i => std_logic_vector(tx_data(7 downto 0)));
   uart_write <= tx_write; --'1' when we_i='1' and addr_i=UART_TX else '0';

   -- Rx timing
   rx_timer : BRGen
      generic map(COUNT => BRDIVISOR)
      port map(
         clk_i => clk_i, reset_i => reset_i, ce_i => br_clk_i, o_o => rx_br);
  br_clk_i <= '1';
  
   -- Tx timing
   tx_timer : BRGen -- 4 Divider for Tx
      generic map(COUNT => 4)  
      port map(
         clk_i => clk_i, reset_i => reset_i, ce_i => rx_br, o_o => tx_br);

end architecture rtl;
