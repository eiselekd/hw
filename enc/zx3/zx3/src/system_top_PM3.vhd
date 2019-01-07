---------------------------------------------------------------------------------------------------
-- Project          : Mars ZX3 Reference Design
-- File description : Top Level
-- File name        : system_top_PM3.vhd
-- Author           : Christoph Glattfelder
---------------------------------------------------------------------------------------------------
-- Copyright (c) 2017 by Enclustra GmbH, Switzerland. All rights are reserved. 
-- Unauthorized duplication of this document, in whole or in part, by any means is prohibited
-- without the prior written permission of Enclustra GmbH, Switzerland.
-- 
-- Although Enclustra GmbH believes that the information included in this publication is correct
-- as of the date of publication, Enclustra GmbH reserves the right to make changes at any time
-- without notice.
-- 
-- All information in this document may only be published by Enclustra GmbH, Switzerland.
---------------------------------------------------------------------------------------------------
-- Description:
-- This is a top-level file for Mars ZX3 Reference Design
--    
---------------------------------------------------------------------------------------------------
-- File history:
--
-- Version | Date       | Author           | Remarks
-- ------------------------------------------------------------------------------------------------
-- 1.0     | 21.01.2014 | C. Glattfelder   | First released version
-- 2.0     | 20.10.2017 | D. Ungureanu     | Consistency checks
--
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- libraries
---------------------------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library unisim;
	use unisim.vcomponents.all;

entity system_top is
	port (
		DDR_addr			: inout std_logic_vector ( 14 downto 0 );
		DDR_ba				: inout std_logic_vector ( 2 downto 0 );
		DDR_cas_n			: inout std_logic;
		DDR_ck_n			: inout std_logic;
		DDR_ck_p			: inout std_logic;
		DDR_cke				: inout std_logic;
		DDR_cs_n			: inout std_logic;
		DDR_dm				: inout std_logic_vector ( 3 downto 0 );
		DDR_dq				: inout std_logic_vector ( 31 downto 0 );
		DDR_dqs_n			: inout std_logic_vector ( 3 downto 0 );
		DDR_dqs_p			: inout std_logic_vector ( 3 downto 0 );
		DDR_odt				: inout std_logic;
		DDR_ras_n			: inout std_logic;
		DDR_reset_n			: inout std_logic;
		DDR_we_n			: inout std_logic;
		
		FIXED_IO_ddr_vrn	: inout std_logic;
		FIXED_IO_ddr_vrp	: inout std_logic;
		FIXED_IO_mio		: inout std_logic_vector ( 53 downto 0 );
		FIXED_IO_ps_clk		: inout std_logic;
		FIXED_IO_ps_porb	: inout std_logic;
		FIXED_IO_ps_srstb	: inout std_logic;

		Eth_Rst_N			: inout	std_logic;
		Usb_Rst_N			: inout	std_logic;

		UART0_TX			: out 	std_logic; 
		UART0_RX 			: in 	std_logic;

		I2C0_SDA			: inout std_logic; 
		I2C0_SCL			: inout std_logic; 
		I2C0_INT_N_pin		: in 	std_logic; 
		
		Rev5				: in	std_logic;
		Rev4				: in	std_logic;

		Led_N 				: out	std_logic_vector(3 downto 0);
		
		-- unused pins, set to high impedance
		Vref0				: inout std_logic; 
		Vref1				: inout std_logic; 
		CLK33				: inout std_logic;
		NAND_WP				: inout std_logic;
		PWR_GOOD_R			: inout std_logic;
        DDR3_VSEL           : inout std_logic;
		
		ETH_Link			: inout std_logic;
		ETH_MDC				: inout std_logic; 
		ETH_MDIO			: inout std_logic; 
		ETH_RX_CLK			: inout std_logic; 
		ETH_RX_CTL			: inout std_logic; 
		ETH_RXD				: inout std_logic_vector(3 downto 0);
		ETH_TX_CLK			: inout std_logic; 
		ETH_TX_CTL			: inout std_logic; 
		ETH_TXD				: inout std_logic_vector(3 downto 0);
		
		--------------------------------------------------
		-- Mars PM3 specific signals
		--------------------------------------------------
		
		-------------------------------------------------------------------------------------------
		-- fmc lpc connector
		-------------------------------------------------------------------------------------------

		FMC_CLK0_M2C_N		: in	std_logic;
		FMC_CLK0_M2C_P		: in	std_logic;
		FMC_CLK1_M2C_N		: in	std_logic;
		FMC_CLK1_M2C_P		: in	std_logic;
		FMC_LA00_CC_N		: inout	std_logic;
		FMC_LA00_CC_P		: inout	std_logic;
		FMC_LA01_CC_N		: inout	std_logic;
		FMC_LA01_CC_P		: inout	std_logic;
		FMC_LA02_N			: inout	std_logic;
		FMC_LA02_P			: inout	std_logic;
		FMC_LA03_N			: inout	std_logic;
		FMC_LA03_P			: inout	std_logic;
		FMC_LA04_N			: inout	std_logic;
		FMC_LA04_P			: inout	std_logic;
		FMC_LA05_N			: inout	std_logic;
		FMC_LA05_P			: inout	std_logic;
		FMC_LA06_N			: inout	std_logic;
		FMC_LA06_P			: inout	std_logic;
		FMC_LA07_N			: inout	std_logic;
		FMC_LA07_P			: inout	std_logic;
		FMC_LA08_N			: inout	std_logic;
		FMC_LA08_P			: inout	std_logic;
		FMC_LA09_N			: inout	std_logic;
		FMC_LA09_P			: inout	std_logic;
		FMC_LA10_N			: inout	std_logic;
		FMC_LA10_P			: inout	std_logic;
		FMC_LA11_N			: inout	std_logic;
		FMC_LA11_P			: inout	std_logic;
		FMC_LA12_N			: inout	std_logic;
		FMC_LA12_P			: inout	std_logic;
		FMC_LA13_N			: inout	std_logic;
		FMC_LA13_P			: inout	std_logic;
		FMC_LA14_N			: inout	std_logic;
		FMC_LA14_P			: inout	std_logic;
		FMC_LA15_N			: inout	std_logic;
		FMC_LA15_P			: inout	std_logic;
		FMC_LA16_N			: inout	std_logic;
		FMC_LA16_P			: inout	std_logic;
		FMC_LA17_CC_N		: inout	std_logic;
		FMC_LA17_CC_P		: inout	std_logic;
		FMC_LA18_CC_N		: inout	std_logic;
		FMC_LA18_CC_P		: inout	std_logic;
		FMC_LA19_N			: inout	std_logic;
		FMC_LA19_P			: inout	std_logic;
		FMC_LA20_N			: inout	std_logic;
		FMC_LA20_P			: inout	std_logic;
		FMC_LA21_N			: inout	std_logic;
		FMC_LA21_P			: inout	std_logic;
		FMC_LA22_N			: inout	std_logic;
		FMC_LA22_P			: inout	std_logic;
		FMC_LA23_N			: inout	std_logic;
		FMC_LA23_P			: inout	std_logic;
		FMC_LA24_N			: inout	std_logic;
		FMC_LA24_P			: inout	std_logic;
		FMC_LA25_N			: inout	std_logic;
		FMC_LA25_P			: inout	std_logic;
		FMC_LA26_N			: inout	std_logic;
		FMC_LA26_P			: inout	std_logic;
		FMC_LA27_N			: inout	std_logic;
		FMC_LA27_P			: inout	std_logic;
		FMC_LA28_N			: inout	std_logic;
		FMC_LA28_P			: inout	std_logic;
		FMC_LA29_N			: inout	std_logic;
		FMC_LA29_P			: inout	std_logic;
		FMC_LA30_N			: inout	std_logic;
		FMC_LA30_P			: inout	std_logic;
		FMC_LA31_N			: inout	std_logic;
		FMC_LA31_P			: inout	std_logic;
		FMC_LA32_N			: inout	std_logic;
		FMC_LA32_P			: inout	std_logic;
		FMC_LA33_N			: inout	std_logic;
		FMC_LA33_P			: inout	std_logic;
	
        -------------------------------------------------------------------------------------------
		-- ez-usb fx3 interface
		-------------------------------------------------------------------------------------------

		FX3_A1				: out	std_logic;
		FX3_CLK				: in	std_logic;
		FX3_DQ0				: inout	std_logic;
		FX3_DQ1_SDD3		: inout	std_logic;
		FX3_DQ10			: inout	std_logic;
		FX3_DQ11			: inout	std_logic;
		FX3_DQ12			: inout	std_logic;
		FX3_DQ13			: inout	std_logic;
		FX3_DQ14			: inout	std_logic;
		FX3_DQ15			: inout	std_logic;
		FX3_DQ2				: inout	std_logic;
		FX3_DQ3_SDD2		: inout	std_logic;
		FX3_DQ4				: inout	std_logic;
		FX3_DQ5				: inout	std_logic;
		FX3_DQ6				: inout	std_logic;
		FX3_DQ7				: inout	std_logic;
		FX3_DQ8				: inout	std_logic;
		FX3_DQ9				: inout	std_logic;
		FX3_FLAGA			: in	std_logic;
		FX3_FLAGB			: in	std_logic;
		FX3_PKTEND_SDD1_N	: out	std_logic;
		FX3_SLOE_SDD0_N		: out	std_logic;
		FX3_SLRD_SDCLK_N	: out	std_logic;
		FX3_SLWR_SDCMD_N	: out	std_logic;
		
        -------------------------------------------------------------------------------------------
		-- hdmi connector
		-------------------------------------------------------------------------------------------

		PCIE_PER0_N			: in	std_logic;
		PCIE_PER0_P			: in	std_logic;
		PCIE_PER1_N			: in	std_logic;
		PCIE_PER1_P			: in	std_logic;
		PCIE_PET0_N			: out	std_logic;
		PCIE_PET0_P			: out	std_logic;
		PCIE_PET1_N			: out	std_logic;
		PCIE_PET1_P			: out	std_logic;
		PCIE_REFCLK_N		: in	std_logic;
		PCIE_REFCLK_P		: in	std_logic
		
		
	);
end system_top;

architecture structure of system_top is

	component testfile is
		port (
			clk		: in std_logic;
			rst		: in std_logic;
			fp      : out std_logic_vector(7 downto 0)
		);
	end component testfile;


	signal IIC_0_sda_i 		: std_logic;
	signal IIC_0_sda_o 		: std_logic;
	signal IIC_0_sda_t 		: std_logic;
	signal IIC_0_scl_i 		: std_logic;
	signal IIC_0_scl_o 		: std_logic;
	signal IIC_0_scl_t 		: std_logic;
	
	signal I2C0_INT_N		: std_logic;

	signal Clk				: std_logic;
	signal Rst				: std_logic := '0';
	signal Rst_N 			: std_logic := '1';
	signal ETH_RST			: std_logic := '0';
	
	signal RstCnt			: unsigned (15 downto 0) := (others => '0'); -- 1ms reset for Ethernet PHY
	
	signal LedCount			: unsigned (23 downto 0);
	signal GPIO				: std_logic_vector (7 downto 0);

	signal SDIO0_CDN_s      : std_logic := '0';
	signal SDIO0_WP_s       : std_logic := '1';
	
	signal fp : std_logic_vector(7 downto 0);
	
begin


	------------------------------------------------------------------------------------------------
	--	Processing System
	------------------------------------------------------------------------------------------------

	v0 : testfile
		port map (
			clk			=> CLK33,
            rst         => Rst,
            fp          => fp
            );

	-- supply voltage for thh DDR3 memory
    DDR3_VSEL       <= '0'; -- 1.35V
--  DDR3_VSEL       <= 'Z'; -- 1.5V

	-- tristate buffer
	I2C0_SDA	<= IIC_0_sda_o when IIC_0_sda_t = '0' else 'Z';
	IIC_0_sda_i <= I2C0_SDA;
	I2C0_SCL	<= IIC_0_scl_o when IIC_0_scl_t = '0' else 'Z';
	IIC_0_scl_i <= I2C0_SCL;

	------------------------------------------------------------------------------------------------
	-- I2C INT inversion
	------------------------------------------------------------------------------------------------
	I2C0_INT_N <= I2C0_INT_N_pin when Rev5 = '0' else not(I2C0_INT_N_pin);

	------------------------------------------------------------------------------------------------
	--	Clock and Reset
	------------------------------------------------------------------------------------------------ 
	   
	--  reset 1ms reset for Ethernet PHY
   	process (Clk)
   	begin
		if rising_edge (Clk) then
   			if (not RstCnt) = 0 then
   				Rst			<= '0';
   			else
   				Rst			<= '1';
   				RstCnt		<= RstCnt + 1;
	   		end if;
   		end if;
   	end process;

    ETH_RST_N <= '0' when Rst = '1' else 'Z';
    USB_RST_N <= '0' when Rst = '1' else 'Z';
    
	------------------------------------------------------------------------------------------------
	-- Blinking LED counter
	------------------------------------------------------------------------------------------------
   
    process (Clk)
    begin
    	if rising_edge (Clk) then
    		if Rst = '1' then
    			LedCount	<= (others => '0');
    		else
    			LedCount <= LedCount + 1;
    		end if;
    	end if;
    end process;
    

    -- Led_N(3) <= not LedCount(LedCount'high);
    -- Led_N(2) <= not GPIO(2);
    -- Led_N(1) <= not GPIO(1);
    -- Led_N(0) <= not GPIO(0);
    Led_N(3) <= fp(0);
    Led_N(2) <= fp(2);
    Led_N(1) <= fp(4);
    Led_N(0) <= fp(6);


	------------------------------------------------------------------------------------------------
	-- Unused pins are set to high impedance in the constraints
	------------------------------------------------------------------------------------------------
end architecture structure;


