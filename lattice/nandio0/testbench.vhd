library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.UART.all;
use work.nandio.all;
use std.textio;
  
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
        signal rst_i    : std_logic;

        signal leds     : std_logic_vector(9 downto 0);

        -- master view
        signal rs232_tx : std_logic;
        signal rs232_rx : std_logic;
        
        signal rx_read  : std_logic := '0';
        signal rx_avail : std_logic;
        signal rx_data  : std_logic_vector(7 downto 0);
        -- tx:
        signal tx_write : std_logic := '0';
        signal tx_busy  : std_logic;
        signal tx_data  : std_logic_vector(7 downto 0);
        
        procedure txc(signal clk : in std_logic;
                      signal tx_write : out std_logic;
                      signal tx_busy : in std_logic;
                      signal tx_data : out std_logic_vector(7 downto 0);
                      data : std_logic_vector(7 downto 0)
                      ) is
        begin
          wait until rising_edge(clk) and tx_busy = '0';
          tx_data <= data;
          tx_write <= '1';
          wait until rising_edge(clk);
          tx_write <= '0';
        end;

        type char_ar is array (natural range <>) of std_logic_vector(7 downto 0);
        
        procedure rxc(signal clk : in std_logic;
                      signal rx_read : out std_logic;
                      signal rx_ready : in std_logic;
                      signal rx_data : in std_logic_vector(7 downto 0);
                      data : out std_logic_vector(7 downto 0)
                      ) is
        begin
            wait until rising_edge(clk) and rx_ready = '1';
            data := rx_data;
            rx_read <= '1';
            wait until rising_edge(clk);
            rx_read <= '0';
        end;

        procedure rxa(signal clk : in std_logic;
                      signal rx_read : out std_logic;
                      signal rx_ready : in std_logic;
                      signal rx_data : in std_logic_vector(7 downto 0);
                      cnt : integer;
                      data : out char_ar
                      ) is
        begin
          for i in 0 to cnt-1 loop
            rxc(clk,rx_read, rx_ready, rx_data, data(i));
          end loop;
        end;


        signal readid : char_ar(0 to 7);
        
begin
	m:nand_model
	port map
          (
              Lock => '0',
              Dq_Io => nand_data(7 downto 0),
              Cle   => nand_cle,
              Ale   => nand_ale,
              Clk_We_n  => nand_nwe,
              Wr_Re_n   => nand_nre,
              Ce_n      => nand_nce,
              Wp_n      => nand_nwp,
              Rb_n      => nand_rnb
              );

        top:nandio_top 
          port map(
            clk_i => clk,
            rstn => rstn,
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
            LED9  => leds(9)
            );        

        u0: uartio 
          port map(
            clk_i => clk,        
            rst_i => rst_i,         
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
        rst_i <= not rstn;
        
        
	CLOCK:process
	begin
          clk <= '1';
          wait for 141.5 ns;
          clk <= '0';
          wait for 141.5 ns;
	end process;
        
	TP: process
          variable readid : char_ar(0 to 7);
	begin
          rstn <= '0';
          wait for 200 ns;
          rstn <= '1';
          wait for 10 ns;
          
          txc(clk,tx_write,tx_busy,tx_data,conv_std_logic_vector(16#01#, 8)); -- cmd cycle 0xff
          txc(clk,tx_write,tx_busy,tx_data,conv_std_logic_vector(16#00#, 8)); -- cmd cycle 0x90
          txc(clk,tx_write,tx_busy,tx_data,conv_std_logic_vector(16#81#, 8)); -- setup addr write cycle cnt 1 
          txc(clk,tx_write,tx_busy,tx_data,conv_std_logic_vector(16#00#, 8)); -- write addr 0 : 0 
          txc(clk,tx_write,tx_busy,tx_data,conv_std_logic_vector(16#48#, 8)); -- setup data read cycle cnt 8
          rxa(clk,rx_read,rx_avail,rx_data, 8, readid);    -- read data 8

          
          wait;
	end process;

end test;
