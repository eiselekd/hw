library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.UART.all;

entity nandio_top is
   port(
      clk_i      : in  std_logic;  -- CPU clock                                                                                 
      rst_i      : in  std_logic;  -- Reset                                                                                     
      break_o    : out std_logic;  -- Break executed                                                                            
      rs232_tx_o : out std_logic;  -- UART Tx                                                                                   
      rs232_rx_i : in  std_logic;  -- UART Rx                                                                                   

      -- NAND chip control hardware interface. These signals should be bound to physical pins.                                  
      nand_cle                          : out   std_logic := '0';
      nand_ale                          : out   std_logic := '0';
      nand_nwe                          : out   std_logic := '1';
      nand_nwp                          : out   std_logic := '0';
      nand_nce                          : out   std_logic := '1';
      nand_nre                          : out   std_logic := '1';
      nand_rnb                          : in    std_logic;
      -- NAND chip data hardware interface. These signals should be boiund to physical pins.                                    
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

   constant CLK_FREQ   : positive:=12; -- 50 MHz clock
   constant BRATE      : positive:=9600; -- RS232 baudrate
   constant BRDIVISOR  : positive:=CLK_FREQ*1e6/BRATE/4;

   -- UART
   -- Rx
   signal rx_br      : std_logic; -- Rx timing
   signal uart_read  : std_logic; -- ZPU read the value
   signal rx_avail   : std_logic; -- Rx data available
   signal rx_data    : std_logic_vector(7 downto 0); -- Rx data
   -- Tx
   signal tx_br      : std_logic; -- Tx timing
   signal uart_write : std_logic; -- ZPU is writing
   signal tx_busy    : std_logic; -- Tx can't get a new value

   signal br_clk_i   : std_logic;

   signal data_i : std_logic_vector(31 downto 0);
   
   type nandio_states is (nandio_idle, nandio_write);
   type regs_nandio is record
      state         : nandio_states;
      cnt           : std_logic_vector(31 downto 0);
      nand_cle      : std_logic;
      nand_ale      : std_logic;
      nand_nwe      : std_logic;
      nand_nwp      : std_logic;
      nand_nce      : std_logic;
      nand_nre      : std_logic;
      nand_data_out : std_logic_vector(15 downto 0);
   end record;

   signal r, rin   : regs_nandio;
   signal clk, rst, reset_i      : std_logic;

begin

  clk <= clk_i;
  rst <= rst_i;
  reset_i <= rst_i;

  sys : process(rst, r)
  variable v : regs_nandio;
  begin
    v := r;
    rin <= v;
    
    nand_cle  <= r.nand_cle;
    nand_ale  <= r.nand_ale;     
    nand_nwe  <= r.nand_nwe;     
    nand_nwp  <= r.nand_nwp;     
    nand_nce  <= r.nand_nce;     
    nand_nre  <= r.nand_nre;     

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
   --uart_read <= '1' when re_i='1' and addr_i=UART_RX else '0';

   -- Tx section
   tx_core : TxUnit
      port map(
         clk_i => clk_i, reset_i => reset_i, enable_i => tx_br,
         load_i => uart_write, txd_o => rs232_tx_o, busy_o => tx_busy,
         datai_i => std_logic_vector(data_i(7 downto 0)));
   --uart_write <= '1' when we_i='1' and addr_i=UART_TX else '0';

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
