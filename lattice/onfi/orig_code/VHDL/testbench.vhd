-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Title							: ONFI compliant NAND interface
-- File							: testbench.vhd
-- Author						: Alexey Lyashko <pradd@opencores.org>
-- License						: LGPL
-------------------------------------------------------------------------------------------------
-- Description:
-- This is the testbench file for the NAND_MASTER module
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onfi.all;

entity tb is
	--port
	--(
	--);
end tb;

architecture test of tb is
	component nand_master
		port
		(
			-- System clock
			clk					: in	std_logic;
			enable					: in	std_logic;
			-- NAND chip control hardware interface. These signals should be bound to physical pins.
			nand_cle				: out	std_logic := '0';
			nand_ale				: out	std_logic := '0';
			nand_nwe				: out	std_logic := '1';
			nand_nwp				: out	std_logic := '0';
			nand_nce				: out	std_logic := '1';
			nand_nre				: out std_logic := '1';
			nand_rnb				: in	std_logic;
			-- NAND chip data hardware interface. These signals should be boiund to physical pins.
			nand_data			: inout	std_logic_vector(15 downto 0);
			
			-- Component interface
			nreset				: in	std_logic := '1';
			data_out				: out	std_logic_vector(7 downto 0);
			data_in				: in	std_logic_vector(7 downto 0);
			busy					: out	std_logic := '0';
			activate				: in	std_logic := '0';
			cmd_in				: in	std_logic_vector(7 downto 0)
		);
	end component;

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
      
	component up_counter
		port
		(
			cnt  : out	std_logic_vector(7 downto 0);
                        enable : in	std_logic;
			clk : in	std_logic;
			reset : in	std_logic
			
		);
	end component;


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

        
        signal cnt  : std_logic_vector(7 downto 0) := (others => '0');
begin

	up:up_counter
          port map
          (
            cnt  =>  cnt,
            enable => '1',
            clk => clk,
            reset => '0'
          
            );

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
  
	NM:nand_master
	port map
	(
		clk => clk,
		enable => '0',
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
	
	CLOCK:process
	begin
		clk <= '1';
		wait for 83ns;  --1.25ns;
		clk <= '0';
		wait for 83ns; -- 1.25ns;
	end process;

	TP: process
	begin
		activate <= '0';
		nreset <= '1';
		--nand_data <= "ZZZZZZZZZZZZZZZZ";
		
		-- Enable the chip
		wait for 2000ns;
		cmd_in <= x"09";
		activate <= '1';
		wait for 1000ns;
		activate <= '0';
		
		
		-- Read JEDEC ID
		data_in <= x"00";
		cmd_in <= x"03";
		wait for 1000ns;
		activate <= '1';
		wait for 1000ns;
		activate <= '0';


		-- Provide ID
		wait for 155ns;
		wait for 32.5ns;
		wait for 32.5ns;
		wait for 32.5ns;
		wait for 32.5ns;
		wait for 32.5ns;
		wait for 5000ns;

                
		-- Read the bytes of the ID
		cmd_in <= x"0e";
		-- 1
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		wait for 2.5ns;
		-- 2
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		wait for 2.5ns;
		-- 3
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		wait for 2.5ns;
		-- 4
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		wait for 2.5ns;
		-- 5
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		
		cmd_in <= x"08";
		wait for 2.5ns;
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		
		
		wait;
	end process;

end test;
