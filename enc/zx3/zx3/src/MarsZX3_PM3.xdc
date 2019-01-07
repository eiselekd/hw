# -------------------------------------------------------------------------------------------------
# -- Project             : Mars ZX3 Reference Design
# -- File description    : Pin assignment and timing constraints file for Mars PM3
# -- File name           : MarsZX3_PM3.xdc
# -- Authors             : Christoph Glattfelder
# -------------------------------------------------------------------------------------------------
# -- Copyright (c) 2017 by Enclustra GmbH, Switzerland. All rights are reserved.
# -- Unauthorized duplication of this document, in whole or in part, by any means is prohibited
# -- without the prior written permission of Enclustra GmbH, Switzerland.
# --
# -- Although Enclustra GmbH believes that the information included in this publication is correct
# -- as of the date of publication, Enclustra GmbH reserves the right to make changes at any time
# -- without notice.
# --
# -- All information in this document may only be published by Enclustra GmbH, Switzerland.
# -------------------------------------------------------------------------------------------------
# -- Notes:
# -- The IO standards might need to be adapted to your design
# -------------------------------------------------------------------------------------------------
# -- File history:
# --
# -- Version | Date       | Author             | Remarks
# -- ----------------------------------------------------------------------------------------------
# -- 1.0     | 21.01.2014 | C. Glattfelder     | First released version
# -- 2.0     | 20.10.2017 | D. Ungureanu       | Consistency checks
# --
# -------------------------------------------------------------------------------------------------

set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design]

# ----------------------------------------------------------------------------------
# Important! Do not remove this constraint!
# This property ensures that all unused pins are set to high impedance.
# If the constraint is removed, all unused pins have to be set to HiZ in the top level file.
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
# ----------------------------------------------------------------------------------

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]

# ----------------------------------------------------------------------------------
# -- revision detection
# ----------------------------------------------------------------------------------
set_property PACKAGE_PIN Y21 [get_ports Rev5]
set_property IOSTANDARD LVCMOS25 [get_ports Rev5]
set_property PULLUP TRUE [get_ports Rev5]

set_property PACKAGE_PIN AB21 [get_ports Rev4]
set_property IOSTANDARD LVCMOS25 [get_ports Rev4]
set_property PULLUP TRUE [get_ports Rev4]

# ----------------------------------------------------------------------------------
# -- system pins
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN U14 [get_ports Usb_Rst_N]
set_property IOSTANDARD LVCMOS25 [get_ports Usb_Rst_N]

set_property PACKAGE_PIN AB11 [get_ports Eth_Rst_N]
set_property IOSTANDARD LVCMOS25 [get_ports Eth_Rst_N]

# ----------------------------------------------------------------------------------
# -- eth I/Os connected in parallel with MIO pins, set to high impedance if not used
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN U12 [get_ports ETH_Link]
set_property IOSTANDARD LVCMOS25 [get_ports ETH_Link]

set_property PACKAGE_PIN AA12 [get_ports ETH_MDC]
set_property IOSTANDARD LVCMOS25 [get_ports ETH_MDC]

set_property PACKAGE_PIN AB12 [get_ports ETH_MDIO]
set_property IOSTANDARD LVCMOS25 [get_ports ETH_MDIO]
set_property PULLUP TRUE [get_ports ETH_MDIO]

set_property PACKAGE_PIN Y9 [get_ports ETH_RX_CLK]
set_property IOSTANDARD LVCMOS25 [get_ports ETH_RX_CLK]

set_property PACKAGE_PIN Y8 [get_ports ETH_RX_CTL]
set_property IOSTANDARD LVCMOS25 [get_ports ETH_RX_CTL]

set_property PACKAGE_PIN U10 [get_ports {ETH_RXD[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {ETH_RXD[0]}]

set_property PACKAGE_PIN Y11 [get_ports {ETH_RXD[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {ETH_RXD[1]}]

set_property PACKAGE_PIN W11 [get_ports {ETH_RXD[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {ETH_RXD[2]}]

set_property PACKAGE_PIN U11 [get_ports {ETH_RXD[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {ETH_RXD[3]}]

set_property PACKAGE_PIN W10 [get_ports ETH_TX_CLK]
set_property IOSTANDARD LVCMOS25 [get_ports ETH_TX_CLK]

set_property PACKAGE_PIN V10 [get_ports ETH_TX_CTL]
set_property IOSTANDARD LVCMOS25 [get_ports ETH_TX_CTL]

set_property PACKAGE_PIN V8 [get_ports {ETH_TXD[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {ETH_TXD[0]}]

set_property PACKAGE_PIN W8 [get_ports {ETH_TXD[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {ETH_TXD[1]}]

set_property PACKAGE_PIN U6 [get_ports {ETH_TXD[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {ETH_TXD[2]}]

set_property PACKAGE_PIN V9 [get_ports {ETH_TXD[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {ETH_TXD[3]}]

# ----------------------------------------------------------------------------------
# -- led
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN H18 [get_ports {Led_N[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {Led_N[0]}]

set_property PACKAGE_PIN AA14 [get_ports {Led_N[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {Led_N[1]}]

set_property PACKAGE_PIN AA13 [get_ports {Led_N[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {Led_N[2]}]

set_property PACKAGE_PIN AB15 [get_ports {Led_N[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {Led_N[3]}]


# ----------------------------------------------------------------------------------
# -- system pins, set to high impedance if not used
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN Y6 [get_ports CLK33]
set_property IOSTANDARD LVCMOS25 [get_ports CLK33]

set_property PACKAGE_PIN AA22 [get_ports DDR3_VSEL]
set_property IOSTANDARD LVCMOS25 [get_ports DDR3_VSEL]

set_property PACKAGE_PIN AB14 [get_ports PWR_GOOD_R]
set_property IOSTANDARD LVCMOS25 [get_ports PWR_GOOD_R]

set_property PACKAGE_PIN V13 [get_ports NAND_WP]
set_property IOSTANDARD LVCMOS25 [get_ports NAND_WP]

set_property PACKAGE_PIN U9 [get_ports Vref0]
set_property IOSTANDARD LVCMOS25 [get_ports Vref0]

set_property PACKAGE_PIN T6 [get_ports Vref1]
set_property IOSTANDARD LVCMOS25 [get_ports Vref1]

# ----------------------------------------------------------------------------------
# -- i2-port
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN H15 [get_ports I2C0_SDA]
set_property IOSTANDARD LVCMOS25 [get_ports I2C0_SDA]

set_property PACKAGE_PIN R15 [get_ports I2C0_SCL]
set_property IOSTANDARD LVCMOS25 [get_ports I2C0_SCL]

set_property PACKAGE_PIN H17 [get_ports I2C0_INT_N_pin]
set_property IOSTANDARD LVCMOS25 [get_ports I2C0_INT_N_pin]

# ----------------------------------------------------------------------------------
# Mars PM3 specific signals
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
# -- UART 
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN N18 [get_ports UART0_TX]
set_property IOSTANDARD LVCMOS25 [get_ports UART0_TX]

set_property PACKAGE_PIN N17 [get_ports UART0_RX]
set_property IOSTANDARD LVCMOS25 [get_ports UART0_RX]


# ----------------------------------------------------------------------------------
# -- hdmi connector
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN R16 [get_ports PCIE_PER0_N]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_PER0_N]
set_property PACKAGE_PIN P16 [get_ports PCIE_PER0_P]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_PER0_P]
set_property PACKAGE_PIN P18 [get_ports PCIE_PER1_N]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_PER1_N]
set_property PACKAGE_PIN P17 [get_ports PCIE_PER1_P]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_PER1_P]
set_property PACKAGE_PIN T18 [get_ports PCIE_PET0_N]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_PET0_N]
set_property PACKAGE_PIN R18 [get_ports PCIE_PET0_P]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_PET0_P]
set_property PACKAGE_PIN T17 [get_ports PCIE_PET1_N]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_PET1_N]
set_property PACKAGE_PIN T16 [get_ports PCIE_PET1_P]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_PET1_P]
set_property PACKAGE_PIN K20 [get_ports PCIE_REFCLK_N]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_REFCLK_N]
set_property PACKAGE_PIN K19 [get_ports PCIE_REFCLK_P]
set_property IOSTANDARD LVCMOS25 [get_ports PCIE_REFCLK_P]

# ----------------------------------------------------------------------------------
# -- fmc lpc connector
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN C19 [get_ports FMC_CLK0_M2C_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_CLK0_M2C_N]
set_property PACKAGE_PIN D18 [get_ports FMC_CLK0_M2C_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_CLK0_M2C_P]
set_property PACKAGE_PIN L19 [get_ports FMC_CLK1_M2C_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_CLK1_M2C_N]
set_property PACKAGE_PIN L18 [get_ports FMC_CLK1_M2C_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_CLK1_M2C_P]
set_property PACKAGE_PIN B20 [get_ports FMC_LA00_CC_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA00_CC_N]
set_property PACKAGE_PIN B19 [get_ports FMC_LA00_CC_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA00_CC_P]
set_property PACKAGE_PIN C20 [get_ports FMC_LA01_CC_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA01_CC_N]
set_property PACKAGE_PIN D20 [get_ports FMC_LA01_CC_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA01_CC_P]
set_property PACKAGE_PIN H20 [get_ports FMC_LA02_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA02_N]
set_property PACKAGE_PIN H19 [get_ports FMC_LA02_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA02_P]
set_property PACKAGE_PIN G21 [get_ports FMC_LA03_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA03_N]
set_property PACKAGE_PIN G20 [get_ports FMC_LA03_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA03_P]
set_property PACKAGE_PIN F22 [get_ports FMC_LA04_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA04_N]
set_property PACKAGE_PIN F21 [get_ports FMC_LA04_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA04_P]
set_property PACKAGE_PIN F19 [get_ports FMC_LA05_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA05_N]
set_property PACKAGE_PIN G19 [get_ports FMC_LA05_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA05_P]
set_property PACKAGE_PIN D21 [get_ports FMC_LA06_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA06_N]
set_property PACKAGE_PIN E21 [get_ports FMC_LA06_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA06_P]
set_property PACKAGE_PIN F17 [get_ports FMC_LA07_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA07_N]
set_property PACKAGE_PIN G17 [get_ports FMC_LA07_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA07_P]
set_property PACKAGE_PIN C22 [get_ports FMC_LA08_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA08_N]
set_property PACKAGE_PIN D22 [get_ports FMC_LA08_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA08_P]
set_property PACKAGE_PIN E16 [get_ports FMC_LA09_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA09_N]
set_property PACKAGE_PIN F16 [get_ports FMC_LA09_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA09_P]
set_property PACKAGE_PIN B22 [get_ports FMC_LA10_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA10_N]
set_property PACKAGE_PIN B21 [get_ports FMC_LA10_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA10_P]
set_property PACKAGE_PIN A22 [get_ports FMC_LA11_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA11_N]
set_property PACKAGE_PIN A21 [get_ports FMC_LA11_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA11_P]
set_property PACKAGE_PIN D17 [get_ports FMC_LA12_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA12_N]
set_property PACKAGE_PIN D16 [get_ports FMC_LA12_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA12_P]
set_property PACKAGE_PIN E18 [get_ports FMC_LA13_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA13_N]
set_property PACKAGE_PIN F18 [get_ports FMC_LA13_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA13_P]
set_property PACKAGE_PIN A19 [get_ports FMC_LA14_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA14_N]
set_property PACKAGE_PIN A18 [get_ports FMC_LA14_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA14_P]
set_property PACKAGE_PIN E20 [get_ports FMC_LA15_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA15_N]
set_property PACKAGE_PIN E19 [get_ports FMC_LA15_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA15_P]
set_property PACKAGE_PIN G22 [get_ports FMC_LA16_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA16_N]
set_property PACKAGE_PIN H22 [get_ports FMC_LA16_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA16_P]
set_property PACKAGE_PIN M20 [get_ports FMC_LA17_CC_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA17_CC_N]
set_property PACKAGE_PIN M19 [get_ports FMC_LA17_CC_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA17_CC_P]
set_property PACKAGE_PIN N20 [get_ports FMC_LA18_CC_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA18_CC_N]
set_property PACKAGE_PIN N19 [get_ports FMC_LA18_CC_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA18_CC_P]
set_property PACKAGE_PIN P22 [get_ports FMC_LA19_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA19_N]
set_property PACKAGE_PIN N22 [get_ports FMC_LA19_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA19_P]
set_property PACKAGE_PIN M16 [get_ports FMC_LA20_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA20_N]
set_property PACKAGE_PIN M15 [get_ports FMC_LA20_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA20_P]
set_property PACKAGE_PIN R21 [get_ports FMC_LA21_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA21_N]
set_property PACKAGE_PIN R20 [get_ports FMC_LA21_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA21_P]
set_property PACKAGE_PIN M17 [get_ports FMC_LA22_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA22_N]
set_property PACKAGE_PIN L17 [get_ports FMC_LA22_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA22_P]
set_property PACKAGE_PIN M22 [get_ports FMC_LA23_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA23_N]
set_property PACKAGE_PIN M21 [get_ports FMC_LA23_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA23_P]
set_property PACKAGE_PIN K21 [get_ports FMC_LA24_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA24_N]
set_property PACKAGE_PIN J20 [get_ports FMC_LA24_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA24_P]
set_property PACKAGE_PIN L22 [get_ports FMC_LA25_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA25_N]
set_property PACKAGE_PIN L21 [get_ports FMC_LA25_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA25_P]
set_property PACKAGE_PIN J17 [get_ports FMC_LA26_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA26_N]
set_property PACKAGE_PIN J16 [get_ports FMC_LA26_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA26_P]
set_property PACKAGE_PIN J22 [get_ports FMC_LA27_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA27_N]
set_property PACKAGE_PIN J21 [get_ports FMC_LA27_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA27_P]
set_property PACKAGE_PIN L16 [get_ports FMC_LA28_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA28_N]
set_property PACKAGE_PIN K16 [get_ports FMC_LA28_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA28_P]
set_property PACKAGE_PIN K18 [get_ports FMC_LA29_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA29_N]
set_property PACKAGE_PIN J18 [get_ports FMC_LA29_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA29_P]
set_property PACKAGE_PIN K15 [get_ports FMC_LA30_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA30_N]
set_property PACKAGE_PIN J15 [get_ports FMC_LA30_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA30_P]
set_property PACKAGE_PIN T19 [get_ports FMC_LA31_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA31_N]
set_property PACKAGE_PIN R19 [get_ports FMC_LA31_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA31_P]
set_property PACKAGE_PIN P15 [get_ports FMC_LA32_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA32_N]
set_property PACKAGE_PIN N15 [get_ports FMC_LA32_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA32_P]
set_property PACKAGE_PIN P21 [get_ports FMC_LA33_N]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA33_N]
set_property PACKAGE_PIN P20 [get_ports FMC_LA33_P]
set_property IOSTANDARD LVCMOS25 [get_ports FMC_LA33_P]

# ----------------------------------------------------------------------------------
# -- ez-usb fx3 interface
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN B15 [get_ports FX3_A1]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_A1]
set_property PACKAGE_PIN B16 [get_ports FX3_CLK]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_CLK]
set_property PACKAGE_PIN U15 [get_ports FX3_DQ0]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ0]
set_property PACKAGE_PIN V17 [get_ports FX3_DQ1_SDD3]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ1_SDD3]
set_property PACKAGE_PIN A16 [get_ports FX3_DQ10]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ10]
set_property PACKAGE_PIN E15 [get_ports FX3_DQ11]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ11]
set_property PACKAGE_PIN C18 [get_ports FX3_DQ12]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ12]
set_property PACKAGE_PIN C17 [get_ports FX3_DQ13]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ13]
set_property PACKAGE_PIN D15 [get_ports FX3_DQ14]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ14]
set_property PACKAGE_PIN G15 [get_ports FX3_DQ15]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ15]
set_property PACKAGE_PIN U16 [get_ports FX3_DQ2]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ2]
set_property PACKAGE_PIN U17 [get_ports FX3_DQ3_SDD2]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ3_SDD2]
set_property PACKAGE_PIN Y16 [get_ports FX3_DQ4]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ4]
set_property PACKAGE_PIN W18 [get_ports FX3_DQ5]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ5]
set_property PACKAGE_PIN W17 [get_ports FX3_DQ6]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ6]
set_property PACKAGE_PIN W16 [get_ports FX3_DQ7]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ7]
set_property PACKAGE_PIN A17 [get_ports FX3_DQ8]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ8]
set_property PACKAGE_PIN G16 [get_ports FX3_DQ9]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_DQ9]
set_property PACKAGE_PIN B17 [get_ports FX3_FLAGA]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_FLAGA]
set_property PACKAGE_PIN C15 [get_ports FX3_FLAGB]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_FLAGB]
set_property PACKAGE_PIN AB17 [get_ports FX3_PKTEND_SDD1_N]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_PKTEND_SDD1_N]
set_property PACKAGE_PIN AA17 [get_ports FX3_SLOE_SDD0_N]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_SLOE_SDD0_N]
set_property PACKAGE_PIN Y18 [get_ports FX3_SLRD_SDCLK_N]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_SLRD_SDCLK_N]
set_property PACKAGE_PIN AA18 [get_ports FX3_SLWR_SDCMD_N]
set_property IOSTANDARD LVCMOS25 [get_ports FX3_SLWR_SDCMD_N]

# ----------------------------------------------------------------------------------
# -- timing constraints
# ----------------------------------------------------------------------------------

create_clock -name CLK33 -period 30.000 [get_ports CLK33]


# ----------------------------------------------------------------------------------------------------
# eof
# ----------------------------------------------------------------------------------------------------
