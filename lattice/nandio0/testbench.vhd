library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.UART.all;

entity tb is
end tb;

architecture test of tb is
        
	-- Internal interface
	signal nand_cle : std_logic;
	signal nand_ale : std_logic;
	signal nand_nwe : std_logic;
	signal nand_nwp : std_logic;
	signal nand_nce :	std_logic;
	signal nand_nre : std_logic;
	signal nand_rnb : std_logic := '1';
	signal nand_data: std_logic_vector(15 downto 0);
	signal nreset   : std_logic := '1';
	signal data_out : std_logic_vector(7 downto 0);
	signal data_in  : std_logic_vector(7 downto 0);
	signal busy     : std_logic;
	signal activate : std_logic;
	signal cmd_in   : std_logic_vector(7 downto 0);
	signal clk	: std_logic := '1';
	signal rstn	: std_logic := '0';

        signal leds     : std_logic_vector(9 downto 0);

        -- master view
        signal rs232_tx : std_logic;
        signal rs232_rx : std_logic;


        signal rx_read  : std_logic;
        signal rx_avail : std_logic;
        signal rx_data  : std_logic_vector(7 downto 0);
        -- tx:
        signal tx_write : std_logic;
        signal tx_busy  : std_logic;
        signal tx_data  : std_logic_vector(7 downto 0)

        
begin
	NM:nand_master
	port map
	(
          clk => clk,
          nand_cle => nand_cle,
          nand_ale => nand_ale,
          nand_nwe => nand_nwe,
          nand_nwp => nand_nwp,
          nand_nce => nand_nce,
          nand_nre => nand_nre,
          nand_rnb => nand_rnb,
          nand_data=> nand_data,
          nreset   => nreset,
          data_out => data_out,
          data_in  => data_in,
          busy     => busy,
          activate => activate,
          cmd_in   => cmd_in
	);

        top:nandio_top 
          port map(
            clk_i => clk,
            rst_i => rstn,
            break_o   => '0',
            rs232_tx_o => rs232_tx,  
            rs232_rx_i => rs232_rx,  

            nand_cle => nand_cle,
            nand_ale => nand_ale,     
            nand_nwe => nand_nwe,
            nand_nwp => nand_nwp,
            nand_nce => nand_nce,
            nand_nre => nand_nre,
            nand_rnb => nand_rnb,
            nand_data => nand_data,

            LED2  => leds(2),
            LED3  => leds(3),
            LED4  => leds(4),
            LED6  => leds(6),
            LED7  => leds(7),
            LED8  => leds(8),
            LED9  => leds(9),
            );        

        u0: uartio 
          port map(
            clk_i => clk,        
            rst_i => rstn,         
            rs232_tx_o => rs232_rx,
            rs232_rx_i => rs232_tx,             
            -- rx:
            rx_read => rx_read,
            rx_avail => rx_avail,
            rx_data => rx_data,
            -- tx:
            tx_write => tx_write,
            tx_busy => tx_busy,
            tx_data => tx_data
            );            
        
        
	CLOCK:process
	begin
          clk <= '1';
          wait for 1.25ns;
          clk <= '0';
          wait for 1.25ns;
	end process;

	TP: process
	begin
          wait;
	end process;

end test;
