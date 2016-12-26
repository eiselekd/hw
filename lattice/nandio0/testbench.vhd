library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
