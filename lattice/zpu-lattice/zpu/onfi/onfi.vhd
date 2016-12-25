library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity onfitop is
	port
	(
		clk				: in	std_logic := '0';
		resetn				: in	std_logic := '0';

                -- uart
                rs232_tx_o : out std_logic;  -- UART Tx
                rs232_rx_i : in  std_logic;  -- UART Rx
		
		-- NAND chip control hardware interface. These signals should be bound to physical pins.
		nand_cle				: out	std_logic := '0';
		nand_ale				: out	std_logic := '0';
		nand_nwe				: out	std_logic := '1';
		nand_nwp				: out	std_logic := '0';
		nand_nce				: out	std_logic := '1';
		nand_nre				: out std_logic := '1';
		nand_rnb				: in	std_logic;
		-- NAND chip data hardware interface. These signals should be boiund to physical pins.
		nand_data			: inout	std_logic_vector(15 downto 0)
		
	);
end onfitop;

architecture action of onfitop is
  
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

   ----------------------
   -- Very simple UART --
   ----------------------
   component RxUnit is
      port(
         clk_i    : in  std_logic;  -- System clock signal
         reset_i  : in  std_logic;  -- Reset input (sync)
         enable_i : in  std_logic;  -- Enable input (rate*4)
         read_i   : in  std_logic;  -- Received Byte Read
         rxd_i    : in  std_logic;  -- RS-232 data input
         rxav_o   : out std_logic;  -- Byte available
         datao_o  : out std_logic_vector(7 downto 0)); -- Byte received
   end component RxUnit;

   component TxUnit is
     port (
        clk_i    : in  std_logic;  -- Clock signal
        reset_i  : in  std_logic;  -- Reset input
        enable_i : in  std_logic;  -- Enable input
        load_i   : in  std_logic;  -- Load input
        txd_o    : out std_logic;  -- RS-232 data output
        busy_o   : out std_logic;  -- Tx Busy
        datai_i  : in  std_logic_vector(7 downto 0)); -- Byte to transmit
   end component TxUnit;

   component BRGen is
     generic(
        COUNT : integer range 0 to 65535);-- Count revolution
     port (
        clk_i   : in  std_logic;  -- Clock
        reset_i : in  std_logic;  -- Reset input
        ce_i    : in  std_logic;  -- Chip Enable
        o_o     : out std_logic); -- Output
   end component BRGen;

   
  
	component nand_master
		port
		(
			nand_cle, nand_ale, nand_nwe, nand_nwp, nand_nce, nand_nre, busy : out std_logic;
			clk, enable, nand_rnb, nreset, activate : in std_logic;
			data_out : out std_logic_vector(7 downto 0);
			data_in, cmd_in : in std_logic_vector(7 downto 0);
			nand_data : inout std_logic_vector(15 downto 0)
		);
	end component;
	signal nreset 			: std_logic;
	signal n_data_out 	: std_logic_vector(7 downto 0);
	signal n_data_in		: std_logic_vector(7 downto 0);
	signal n_busy			: std_logic;
	signal n_activate		: std_logic;
	signal n_cmd_in		: std_logic_vector(7 downto 0);
	signal prev_pwrite	: std_logic;
	signal prev_address	: std_logic_vector(1 downto 0);
begin
	NANDA: nand_master
	port map
	(
		clk => clk, enable => '0',
		nand_cle => nand_cle, nand_ale => nand_ale, nand_nwe => nand_nwe, nand_nwp => nand_nwp, nand_nce => nand_nce, nand_nre => nand_nre,
		nand_rnb => nand_rnb, nand_data => nand_data,
		nreset => resetn, data_out => n_data_out, data_in => n_data_in, busy => n_busy, activate => n_activate, cmd_in => n_cmd_in
	);
	
	-- Registers:
	-- 0x00:		Data IO
	-- 0x04:		Command input
	-- 0x08:		Status output
	
									
   ----------
   -- UART --
   ----------
   -- Rx section
   rx_core : RxUnit
      port map(
         clk_i => clk_i, reset_i => reset_i, enable_i => rx_br,
         read_i => uart_read, rxd_i => rs232_rx_i, rxav_o => rx_avail,
         datao_o => rx_data);
   uart_read <= '1' when re_i='1' and addr_i=UART_RX else '0';

   -- Tx section
   tx_core : TxUnit
      port map(
         clk_i => clk_i, reset_i => reset_i, enable_i => tx_br,
         load_i => uart_write, txd_o => rs232_tx_o, busy_o => tx_busy,
         datai_i => std_logic_vector(data_i(7 downto 0)));
   uart_write <= '1' when we_i='1' and addr_i=UART_TX else '0';

   -- Rx timing
   rx_timer : BRGen
      generic map(COUNT => BRDIVISOR)
      port map(
         clk_i => clk_i, reset_i => reset_i, ce_i => br_clk_i, o_o => rx_br);

   -- Tx timing
   tx_timer : BRGen -- 4 Divider for Tx
      generic map(COUNT => 4)  
      port map(
         clk_i => clk_i, reset_i => reset_i, ce_i => rx_br, o_o => tx_br);
   

end action;
