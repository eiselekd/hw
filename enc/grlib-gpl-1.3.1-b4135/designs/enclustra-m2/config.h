/*
 * Automatically generated C config: don't edit
 */
#define AUTOCONF_INCLUDED
#define CONFIG_LEON3FT_PRESENT 1
#define CONFIG_HAS_SHARED_GRFPU 1
/*
 * Synthesis      
 */
#undef  CONFIG_SYN_INFERRED
#undef  CONFIG_SYN_STRATIX
#undef  CONFIG_SYN_STRATIXII
#undef  CONFIG_SYN_STRATIXIII
#undef  CONFIG_SYN_STRATIXIV
#undef  CONFIG_SYN_CYCLONEIII
#undef  CONFIG_SYN_ALTERA
#undef  CONFIG_SYN_AXCEL
#undef  CONFIG_SYN_AXDSP
#undef  CONFIG_SYN_PROASIC
#undef  CONFIG_SYN_PROASICPLUS
#undef  CONFIG_SYN_PROASIC3
#undef  CONFIG_SYN_PROASIC3E
#undef  CONFIG_SYN_PROASIC3L
#undef  CONFIG_SYN_IGLOO
#undef  CONFIG_SYN_FUSION
#undef  CONFIG_SYN_UT025CRH
#undef  CONFIG_SYN_UT130HBD
#undef  CONFIG_SYN_UT90NHBD
#undef  CONFIG_SYN_ATC18
#undef  CONFIG_SYN_ATC18RHA
#undef  CONFIG_SYN_CMOS9SF
#undef  CONFIG_SYN_CUSTOM1
#undef  CONFIG_SYN_EASIC90
#undef  CONFIG_SYN_EASIC45
#undef  CONFIG_SYN_IHP25
#undef  CONFIG_SYN_IHP25RH
#undef  CONFIG_SYN_LATTICE
#undef  CONFIG_SYN_ECLIPSE
#undef  CONFIG_SYN_PEREGRINE
#undef  CONFIG_SYN_RH_LIB18T
#undef  CONFIG_SYN_RHUMC
#undef  CONFIG_SYN_SMIC13
#undef  CONFIG_SYN_TM65GPLUS
#undef  CONFIG_SYN_TSMC90
#undef  CONFIG_SYN_UMC
#undef  CONFIG_SYN_ARTIX7
#undef  CONFIG_SYN_KINTEX7
#undef  CONFIG_SYN_SPARTAN3
#undef  CONFIG_SYN_SPARTAN3E
#define CONFIG_SYN_SPARTAN6 1
#undef  CONFIG_SYN_VIRTEX
#undef  CONFIG_SYN_VIRTEXE
#undef  CONFIG_SYN_VIRTEX2
#undef  CONFIG_SYN_VIRTEX4
#undef  CONFIG_SYN_VIRTEX5
#undef  CONFIG_SYN_VIRTEX6
#undef  CONFIG_SYN_VIRTEX7
#undef  CONFIG_SYN_ZYNQ7000
#undef  CONFIG_SYN_INFER_RAM
#undef  CONFIG_SYN_INFER_PADS
#undef  CONFIG_SYN_NO_ASYNC
#undef  CONFIG_SYN_SCAN
/*
 * Clock generation
 */
#undef  CONFIG_CLK_INFERRED
#undef  CONFIG_CLK_HCLKBUF
#undef  CONFIG_CLK_UT130HBD
#undef  CONFIG_CLK_ALTDLL
#undef  CONFIG_CLK_LATDLL
#undef  CONFIG_CLK_PRO3PLL
#undef  CONFIG_CLK_PRO3EPLL
#undef  CONFIG_CLK_PRO3LPLL
#undef  CONFIG_CLK_FUSPLL
#undef  CONFIG_CLK_LIB18T
#undef  CONFIG_CLK_RHUMC
#undef  CONFIG_CLK_CLKPLLE2
#undef  CONFIG_CLK_CLKDLL
#define CONFIG_CLK_DCM 1
#define CONFIG_CLK_MUL (2)
#define CONFIG_CLK_DIV (2)
#undef  CONFIG_PCI_CLKDLL
#undef  CONFIG_CLK_NOFB
#undef  CONFIG_PCI_SYSCLK
/*
 * Processor            
 */
#undef  CONFIG_LEON3
/*
 * AMBA configuration
 */
#define CONFIG_AHB_DEFMST (0)
#define CONFIG_AHB_RROBIN 1
#undef  CONFIG_AHB_SPLIT
#define CONFIG_AHB_FPNPEN 1
#define CONFIG_AHB_IOADDR FFF
#define CONFIG_APB_HADDR 800
#undef  CONFIG_AHB_MON
#undef  CONFIG_AHB_DTRACE
/*
 * Debug Link           
 */
#define CONFIG_DSU_UART 1
#define CONFIG_DSU_JTAG 1
/*
 * Peripherals             
 */
/*
 * Memory controller             
 */
/*
 * Leon2 memory controller        
 */
#undef  CONFIG_MCTRL_LEON2
/*
 * DDR2 SDRAM controller             
 */
#undef  CONFIG_DDR2SP
/*
 * MIG memory controller   
 */
#undef  CONFIG_MIG_DDR2
#undef  CONFIG_AHBSTAT_ENABLE
/*
 * On-chip RAM/ROM                 
 */
#undef  CONFIG_AHBROM_ENABLE
#define CONFIG_AHBRAM_ENABLE 1
#undef  CONFIG_AHBRAM_SZ1
#undef  CONFIG_AHBRAM_SZ2
#undef  CONFIG_AHBRAM_SZ4
#undef  CONFIG_AHBRAM_SZ8
#undef  CONFIG_AHBRAM_SZ16
#undef  CONFIG_AHBRAM_SZ32
#undef  CONFIG_AHBRAM_SZ64
#define CONFIG_AHBRAM_SZ128 1
#undef  CONFIG_AHBRAM_SZ256
#undef  CONFIG_AHBRAM_SZ512
#undef  CONFIG_AHBRAM_SZ1024
#undef  CONFIG_AHBRAM_SZ2048
#undef  CONFIG_AHBRAM_SZ4096
#define CONFIG_AHBRAM_START 400
#undef  CONFIG_AHBRAM_PIPE
/*
 * Ethernet             
 */
#undef  CONFIG_GRETH_ENABLE
/*
 * CAN                     
 */
#undef  CONFIG_CAN_ENABLE
/*
 * UART, timer, I/O port and interrupt controller
 */
#define CONFIG_UART1_ENABLE 1
#undef  CONFIG_UA1_FIFO1
#undef  CONFIG_UA1_FIFO2
#define CONFIG_UA1_FIFO4 1
#undef  CONFIG_UA1_FIFO8
#undef  CONFIG_UA1_FIFO16
#undef  CONFIG_UA1_FIFO32
#define CONFIG_IRQ3_ENABLE 1
#undef  CONFIG_IRQ3_SEC
#define CONFIG_GPT_ENABLE 1
#define CONFIG_GPT_NTIM (2)
#define CONFIG_GPT_SW (8)
#define CONFIG_GPT_TW (32)
#define CONFIG_GPT_IRQ (8)
#define CONFIG_GPT_SEPIRQ 1
#undef  CONFIG_GPT_WDOGEN
#undef  CONFIG_GRGPIO_ENABLE
/*
 * I2C master         
 */
#define CONFIG_I2C_ENABLE 1
/*
 * Spacewire 
 */
#undef  CONFIG_SPW_ENABLE
/*
 * Keybord and VGA interface
 */
#undef  CONFIG_KBD_ENABLE
#undef  CONFIG_VGA_ENABLE
#undef  CONFIG_SVGA_ENABLE
/*
 * SPI
 */
/*
 * SPI memory controller 
 */
#undef  CONFIG_SPIMCTRL
/*
 * SPI controller(s) 
 */
#undef  CONFIG_SPICTRL_ENABLE
/*
 * VHDL Debugging        
 */
#define CONFIG_DEBUG_UART 1
