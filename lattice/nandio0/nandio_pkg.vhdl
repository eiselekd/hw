library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package nandio is

  component nandio_top is
   port(
      clk_i      : in  std_logic;  -- CPU clock                                                                                 
      rstn       : in  std_logic;  -- Reset                                                                                     
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
   end component nandio_top;


  component nand_model
          port
            (
              Lock  : in std_logic;
              Dq_Io : inout std_logic_vector(7 downto 0);
              Cle   : in std_logic;
              Ale   : in  std_logic;
              Clk_We_n  : in  std_logic;
              Wr_Re_n   : in  std_logic;
              Ce_n      : in  std_logic;
              Wp_n      : in  std_logic;
              Rb_n      : out std_logic
              );
  end component;


  function notx(d : std_logic_vector) return boolean;
  function "+" (d : std_logic_vector; i : integer) return std_logic_vector;
  function "-" (d : std_logic_vector; i : integer) return std_logic_vector;
  function conv_std_logic_vector(i : integer; w : integer) return std_logic_vector;
  
end package nandio;


package body nandio is

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

   function "-" (d : std_logic_vector; i : integer) return std_logic_vector is
     variable x : std_logic_vector(d'length-1 downto 0);
   begin
   -- pragma translate_off
     if notx(d) then
   -- pragma translate_on
       return(std_logic_vector(unsigned(d) - i));
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
   
end;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package UART is
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

   component uartio is
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
   end component uartio;
   
end package UART;
