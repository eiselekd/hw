-- Technology and synthesis options
  constant CFG_FABTECH 	: integer := CONFIG_SYN_TECH;
  constant CFG_MEMTECH  : integer := CFG_RAM_TECH;
  constant CFG_PADTECH 	: integer := CFG_PAD_TECH;
  constant CFG_NOASYNC 	: integer := CONFIG_SYN_NO_ASYNC;
  constant CFG_SCAN 	: integer := CONFIG_SYN_SCAN;

-- Clock generator
  constant CFG_CLKTECH 	: integer := CFG_CLK_TECH;
  constant CFG_CLKMUL   : integer := CONFIG_CLK_MUL;
  constant CFG_CLKDIV   : integer := CONFIG_CLK_DIV;
  constant CFG_OCLKDIV  : integer := CONFIG_OCLK_DIV;
  constant CFG_OCLKBDIV : integer := CONFIG_OCLKB_DIV;
  constant CFG_OCLKCDIV : integer := CONFIG_OCLKC_DIV;
  constant CFG_PCIDLL   : integer := CONFIG_PCI_CLKDLL;
  constant CFG_PCISYSCLK: integer := CONFIG_PCI_SYSCLK;
  constant CFG_CLK_NOFB : integer := CONFIG_CLK_NOFB;

-- LEON3 processor core
  constant CFG_LEON3  	: integer := CONFIG_LEON3;
  constant CFG_NCPU 	: integer := CONFIG_PROC_NUM;
  constant CFG_NWIN 	: integer := CONFIG_IU_NWINDOWS;
  constant CFG_V8   	: integer := CFG_IU_V8 + 4*CFG_IU_MUL_STRUCT;
  constant CFG_MAC  	: integer := CONFIG_IU_MUL_MAC;
  constant CFG_BP   	: integer := CONFIG_IU_BP;
  constant CFG_SVT  	: integer := CONFIG_IU_SVT;
  constant CFG_RSTADDR 	: integer := 16#CONFIG_IU_RSTADDR#;
  constant CFG_LDDEL	: integer := CONFIG_IU_LDELAY;
  constant CFG_NOTAG	: integer := CONFIG_NOTAG;
  constant CFG_NWP  	: integer := CONFIG_IU_WATCHPOINTS;
  constant CFG_PWD 	: integer := CONFIG_PWD*2;
  constant CFG_FPU 	: integer := CONFIG_FPU + 16*CONFIG_FPU_NETLIST + 32*CONFIG_FPU_GRFPU_SHARED;
  constant CFG_GRFPUSH  : integer := CONFIG_FPU_GRFPU_SHARED;
  constant CFG_ICEN  	: integer := CONFIG_ICACHE_ENABLE;
  constant CFG_ISETS	: integer := CFG_IU_ISETS;
  constant CFG_ISETSZ	: integer := CFG_ICACHE_SZ;
  constant CFG_ILINE 	: integer := CFG_ILINE_SZ;
  constant CFG_IREPL 	: integer := CFG_ICACHE_ALGORND;
  constant CFG_ILOCK 	: integer := CONFIG_ICACHE_LOCK;
  constant CFG_ILRAMEN	: integer := CONFIG_ICACHE_LRAM;
  constant CFG_ILRAMADDR: integer := 16#CONFIG_ICACHE_LRSTART#;
  constant CFG_ILRAMSZ	: integer := CFG_ILRAM_SIZE;
  constant CFG_DCEN  	: integer := CONFIG_DCACHE_ENABLE;
  constant CFG_DSETS	: integer := CFG_IU_DSETS;
  constant CFG_DSETSZ	: integer := CFG_DCACHE_SZ;
  constant CFG_DLINE 	: integer := CFG_DLINE_SZ;
  constant CFG_DREPL 	: integer := CFG_DCACHE_ALGORND;
  constant CFG_DLOCK 	: integer := CONFIG_DCACHE_LOCK;
  constant CFG_DSNOOP	: integer := CONFIG_DCACHE_SNOOP + CONFIG_DCACHE_SNOOP_FAST + 4*CONFIG_DCACHE_SNOOP_SEPTAG;
  constant CFG_DFIXED	: integer := 16#CONFIG_CACHE_FIXED#;
  constant CFG_DLRAMEN	: integer := CONFIG_DCACHE_LRAM;
  constant CFG_DLRAMADDR: integer := 16#CONFIG_DCACHE_LRSTART#;
  constant CFG_DLRAMSZ	: integer := CFG_DLRAM_SIZE;
  constant CFG_MMUEN    : integer := CONFIG_MMUEN;
  constant CFG_ITLBNUM  : integer := CONFIG_ITLBNUM;
  constant CFG_DTLBNUM  : integer := CONFIG_DTLBNUM;
  constant CFG_TLB_TYPE : integer := CONFIG_TLB_TYPE + CFG_MMU_FASTWB*2;
  constant CFG_TLB_REP  : integer := CONFIG_TLB_REP;
  constant CFG_MMU_PAGE : integer := CONFIG_MMU_PAGE;
  constant CFG_DSU   	: integer := CONFIG_DSU_ENABLE;
  constant CFG_ITBSZ 	: integer := CFG_DSU_ITB;
  constant CFG_ATBSZ 	: integer := CFG_DSU_ATB;
  constant CFG_LEON3FT_EN   : integer := CONFIG_LEON3FT_EN;
  constant CFG_IUFT_EN      : integer := CONFIG_IUFT_EN;
  constant CFG_FPUFT_EN     : integer := CONFIG_FPUFT;
  constant CFG_RF_ERRINJ    : integer := CONFIG_RF_ERRINJ;	
  constant CFG_CACHE_FT_EN  : integer := CONFIG_CACHE_FT_EN;
  constant CFG_CACHE_ERRINJ : integer := CONFIG_CACHE_ERRINJ;	
  constant CFG_LEON3_NETLIST: integer := CONFIG_LEON3_NETLIST;	
  constant CFG_DISAS    : integer := CONFIG_IU_DISAS + CONFIG_IU_DISAS_NET;
  constant CFG_PCLOW    : integer := CFG_DEBUG_PC32;

-- AMBA settings
  constant CFG_DEFMST  	  : integer := CONFIG_AHB_DEFMST;
  constant CFG_RROBIN  	  : integer := CONFIG_AHB_RROBIN;
  constant CFG_SPLIT   	  : integer := CONFIG_AHB_SPLIT;
  constant CFG_FPNPEN  	  : integer := CONFIG_AHB_FPNPEN;
  constant CFG_AHBIO   	  : integer := 16#CONFIG_AHB_IOADDR#;
  constant CFG_APBADDR 	  : integer := 16#CONFIG_APB_HADDR#;
  constant CFG_AHB_MON 	  : integer := CONFIG_AHB_MON;
  constant CFG_AHB_MONERR : integer := CONFIG_AHB_MONERR;
  constant CFG_AHB_MONWAR : integer := CONFIG_AHB_MONWAR;
  constant CFG_AHB_DTRACE : integer := CONFIG_AHB_DTRACE;

-- DSU UART
  constant CFG_AHB_UART	: integer := CONFIG_DSU_UART;

-- JTAG based DSU interface
  constant CFG_AHB_JTAG	: integer := CONFIG_DSU_JTAG;

-- USB DSU
  constant CFG_GRUSB_DCL        : integer := CONFIG_GRUSB_DCL;
  constant CFG_GRUSB_DCL_UIFACE : integer := CONFIG_GRUSB_DCL_UIFACE;
  constant CFG_GRUSB_DCL_DW     : integer := CONFIG_GRUSB_DCL_DW;

-- Ethernet DSU
  constant CFG_DSU_ETH	: integer := CONFIG_DSU_ETH + CONFIG_DSU_ETH_PROG + CONFIG_DSU_ETH_DIS;
  constant CFG_ETH_BUF 	: integer := CFG_DSU_ETHB;
  constant CFG_ETH_IPM 	: integer := 16#CONFIG_DSU_IPMSB#;
  constant CFG_ETH_IPL 	: integer := 16#CONFIG_DSU_IPLSB#;
  constant CFG_ETH_ENM 	: integer := 16#CONFIG_DSU_ETHMSB#;
  constant CFG_ETH_ENL 	: integer := 16#CONFIG_DSU_ETHLSB#;

-- LEON2 memory controller
  constant CFG_MCTRL_LEON2    : integer := CONFIG_MCTRL_LEON2;
  constant CFG_MCTRL_RAM8BIT  : integer := CONFIG_MCTRL_8BIT;
  constant CFG_MCTRL_RAM16BIT : integer := CONFIG_MCTRL_16BIT;
  constant CFG_MCTRL_5CS      : integer := CONFIG_MCTRL_5CS;
  constant CFG_MCTRL_SDEN     : integer := CONFIG_MCTRL_SDRAM;
  constant CFG_MCTRL_SEPBUS   : integer := CONFIG_MCTRL_SDRAM_SEPBUS;
  constant CFG_MCTRL_INVCLK   : integer := CONFIG_MCTRL_SDRAM_INVCLK;
  constant CFG_MCTRL_SD64     : integer := CONFIG_MCTRL_SDRAM_BUS64;
  constant CFG_MCTRL_PAGE     : integer := CONFIG_MCTRL_PAGE + CONFIG_MCTRL_PROGPAGE;

-- Xilinx MIG
  constant CFG_MIG_DDR2    : integer := CONFIG_MIG_DDR2;
  constant CFG_MIG_RANKS   : integer := CONFIG_MIG_RANKS;
  constant CFG_MIG_COLBITS : integer := CONFIG_MIG_COLBITS;
  constant CFG_MIG_ROWBITS : integer := CONFIG_MIG_ROWBITS;
  constant CFG_MIG_BANKBITS: integer := CONFIG_MIG_BANKBITS;
  constant CFG_MIG_HMASK   : integer := 16#CONFIG_MIG_HMASK#;


-- Xilinx MIG Series 7
  constant CFG_MIG_SERIES7    : integer := CONFIG_MIG_SERIES7;

-- AHB status register
  constant CFG_AHBSTAT 	: integer := CONFIG_AHBSTAT_ENABLE;
  constant CFG_AHBSTATN	: integer := CONFIG_AHBSTAT_NFTSLV;

-- AHB ROM
  constant CFG_AHBROMEN	: integer := CONFIG_AHBROM_ENABLE;
  constant CFG_AHBROPIP	: integer := CONFIG_AHBROM_PIPE;
  constant CFG_AHBRODDR	: integer := 16#CONFIG_AHBROM_START#;
  constant CFG_ROMADDR	: integer := 16#CONFIG_ROM_START#;
  constant CFG_ROMMASK	: integer := 16#E00# + 16#CONFIG_ROM_START#;

-- AHB RAM
  constant CFG_AHBRAMEN	: integer := CONFIG_AHBRAM_ENABLE;
  constant CFG_AHBRSZ	: integer := CFG_AHBRAMSZ;
  constant CFG_AHBRADDR	: integer := 16#CONFIG_AHBRAM_START#;
  constant CFG_AHBRPIPE : integer := CONFIG_AHBRAM_PIPE;
-- Gaisler Ethernet core
  constant CFG_GRETH   	: integer := CONFIG_GRETH_ENABLE;
  constant CFG_GRETH1G	: integer := CONFIG_GRETH_GIGA;
  constant CFG_ETH_FIFO : integer := CFG_GRETH_FIFO;

-- USB Host Controller
  constant CFG_GRUSBHC          : integer := CONFIG_GRUSBHC_ENABLE;
  constant CFG_GRUSBHC_NPORTS   : integer := CONFIG_GRUSBHC_NPORTS;
  constant CFG_GRUSBHC_EHC      : integer := CONFIG_GRUSBHC_EHC;
  constant CFG_GRUSBHC_UHC      : integer := CONFIG_GRUSBHC_UHC;
  constant CFG_GRUSBHC_NCC      : integer := CONFIG_GRUSBHC_NCC;
  constant CFG_GRUSBHC_NPCC     : integer := CONFIG_GRUSBHC_NPCC;
  constant CFG_GRUSBHC_PRR      : integer := CONFIG_GRUSBHC_PRR;
  constant CFG_GRUSBHC_PR1      : integer := CONFIG_GRUSBHC_PORTROUTE1;
  constant CFG_GRUSBHC_PR2      : integer := CONFIG_GRUSBHC_PORTROUTE2;
  constant CFG_GRUSBHC_ENDIAN   : integer := CONFIG_GRUSBHC_ENDIAN;
  constant CFG_GRUSBHC_BEREGS   : integer := CONFIG_GRUSBHC_BEREGS;
  constant CFG_GRUSBHC_BEDESC   : integer := CONFIG_GRUSBHC_BEDESC;
  constant CFG_GRUSBHC_BLO      : integer := CONFIG_GRUSBHC_BLO;
  constant CFG_GRUSBHC_BWRD     : integer := CONFIG_GRUSBHC_BWRD;
  constant CFG_GRUSBHC_UTM      : integer := CONFIG_GRUSBHC_UTMTYPE;
  constant CFG_GRUSBHC_VBUSCONF : integer := CONFIG_GRUSBHC_VBUSCONF;

-- GR USB 2.0 Device Controller
  constant CFG_GRUSBDC        : integer := CONFIG_GRUSBDC_ENABLE;
  constant CFG_GRUSBDC_AIFACE : integer := CONFIG_GRUSBDC_AIFACE;
  constant CFG_GRUSBDC_UIFACE : integer := CONFIG_GRUSBDC_UIFACE;
  constant CFG_GRUSBDC_DW     : integer := CONFIG_GRUSBDC_DW;
  constant CFG_GRUSBDC_NEPI   : integer := CONFIG_GRUSBDC_NEPI;
  constant CFG_GRUSBDC_NEPO   : integer := CONFIG_GRUSBDC_NEPO;
  constant CFG_GRUSBDC_I0     : integer := CONFIG_GRUSBDC_I0;
  constant CFG_GRUSBDC_I1     : integer := CONFIG_GRUSBDC_I1;
  constant CFG_GRUSBDC_I2     : integer := CONFIG_GRUSBDC_I2;
  constant CFG_GRUSBDC_I3     : integer := CONFIG_GRUSBDC_I3;
  constant CFG_GRUSBDC_I4     : integer := CONFIG_GRUSBDC_I4;
  constant CFG_GRUSBDC_I5     : integer := CONFIG_GRUSBDC_I5;
  constant CFG_GRUSBDC_I6     : integer := CONFIG_GRUSBDC_I6;
  constant CFG_GRUSBDC_I7     : integer := CONFIG_GRUSBDC_I7;
  constant CFG_GRUSBDC_I8     : integer := CONFIG_GRUSBDC_I8;
  constant CFG_GRUSBDC_I9     : integer := CONFIG_GRUSBDC_I9;
  constant CFG_GRUSBDC_I10    : integer := CONFIG_GRUSBDC_I10;
  constant CFG_GRUSBDC_I11    : integer := CONFIG_GRUSBDC_I11;
  constant CFG_GRUSBDC_I12    : integer := CONFIG_GRUSBDC_I12;
  constant CFG_GRUSBDC_I13    : integer := CONFIG_GRUSBDC_I13;
  constant CFG_GRUSBDC_I14    : integer := CONFIG_GRUSBDC_I14;
  constant CFG_GRUSBDC_I15    : integer := CONFIG_GRUSBDC_I15;
  constant CFG_GRUSBDC_O0     : integer := CONFIG_GRUSBDC_O0;
  constant CFG_GRUSBDC_O1     : integer := CONFIG_GRUSBDC_O1;
  constant CFG_GRUSBDC_O2     : integer := CONFIG_GRUSBDC_O2;
  constant CFG_GRUSBDC_O3     : integer := CONFIG_GRUSBDC_O3;
  constant CFG_GRUSBDC_O4     : integer := CONFIG_GRUSBDC_O4;
  constant CFG_GRUSBDC_O5     : integer := CONFIG_GRUSBDC_O5;
  constant CFG_GRUSBDC_O6     : integer := CONFIG_GRUSBDC_O6;
  constant CFG_GRUSBDC_O7     : integer := CONFIG_GRUSBDC_O7;
  constant CFG_GRUSBDC_O8     : integer := CONFIG_GRUSBDC_O8;
  constant CFG_GRUSBDC_O9     : integer := CONFIG_GRUSBDC_O9;
  constant CFG_GRUSBDC_O10    : integer := CONFIG_GRUSBDC_O10;
  constant CFG_GRUSBDC_O11    : integer := CONFIG_GRUSBDC_O11;
  constant CFG_GRUSBDC_O12    : integer := CONFIG_GRUSBDC_O12;
  constant CFG_GRUSBDC_O13    : integer := CONFIG_GRUSBDC_O13;
  constant CFG_GRUSBDC_O14    : integer := CONFIG_GRUSBDC_O14;
  constant CFG_GRUSBDC_O15    : integer := CONFIG_GRUSBDC_O15;
-- CAN 2.0 interface
  constant CFG_CAN      : integer := CONFIG_CAN_ENABLE;
  constant CFG_CAN_NUM  : integer := CONFIG_CAN_NUM;
  constant CFG_CANIO    : integer := 16#CONFIG_CANIO#;
  constant CFG_CANIRQ   : integer := CONFIG_CANIRQ;
  constant CFG_CANSEPIRQ: integer := CONFIG_CANSEPIRQ;
  constant CFG_CAN_SYNCRST : integer := CONFIG_CAN_SYNCRST;
  constant CFG_CANFT    : integer := CONFIG_CAN_FT;

-- Spacewire interface
  constant CFG_SPW_EN      : integer := CONFIG_SPW_ENABLE;
  constant CFG_SPW_NUM     : integer := CONFIG_SPW_NUM;
  constant CFG_SPW_AHBFIFO : integer := CONFIG_SPW_AHBFIFO;
  constant CFG_SPW_RXFIFO  : integer := CONFIG_SPW_RXFIFO;
  constant CFG_SPW_RMAP    : integer := CONFIG_SPW_RMAP;
  constant CFG_SPW_RMAPBUF : integer := CONFIG_SPW_RMAPBUF;
  constant CFG_SPW_RMAPCRC : integer := CONFIG_SPW_RMAPCRC;
  constant CFG_SPW_NETLIST : integer := CONFIG_SPW_NETLIST;
  constant CFG_SPW_FT      : integer := CONFIG_SPW_FT;
  constant CFG_SPW_GRSPW   : integer := CONFIG_SPW_GRSPW;
  constant CFG_SPW_RXUNAL  : integer := CONFIG_SPW_RXUNAL;
  constant CFG_SPW_DMACHAN : integer := CONFIG_SPW_DMACHAN;
  constant CFG_SPW_PORTS   : integer := CONFIG_SPW_PORTS;
  constant CFG_SPW_INPUT   : integer := CONFIG_SPW_INPUT;
  constant CFG_SPW_OUTPUT  : integer := CONFIG_SPW_OUTPUT;
  constant CFG_SPW_RTSAME  : integer := CONFIG_SPW_RTSAME;
-- UART 1
  constant CFG_UART1_ENABLE : integer := CONFIG_UART1_ENABLE;
  constant CFG_UART1_FIFO   : integer := CFG_UA1_FIFO;

-- LEON3 interrupt controller
  constant CFG_IRQ3_ENABLE  : integer := CONFIG_IRQ3_ENABLE;
  constant CFG_IRQ3_NSEC    : integer := CONFIG_IRQ3_NSEC;

-- Modular timer
  constant CFG_GPT_ENABLE   : integer := CONFIG_GPT_ENABLE;
  constant CFG_GPT_NTIM     : integer := CONFIG_GPT_NTIM;
  constant CFG_GPT_SW       : integer := CONFIG_GPT_SW;
  constant CFG_GPT_TW       : integer := CONFIG_GPT_TW;
  constant CFG_GPT_IRQ      : integer := CONFIG_GPT_IRQ;
  constant CFG_GPT_SEPIRQ   : integer := CONFIG_GPT_SEPIRQ;
  constant CFG_GPT_WDOGEN   : integer := CONFIG_GPT_WDOGEN;
  constant CFG_GPT_WDOG     : integer := 16#CONFIG_GPT_WDOG#;

-- GPIO port
  constant CFG_GRGPIO_ENABLE : integer := CONFIG_GRGPIO_ENABLE;
  constant CFG_GRGPIO_IMASK  : integer := 16#CONFIG_GRGPIO_IMASK#;
  constant CFG_GRGPIO_WIDTH  : integer := CONFIG_GRGPIO_WIDTH;

-- I2C master
  constant CFG_I2C_ENABLE : integer := CONFIG_I2C_ENABLE;

-- VGA and PS2/ interface
  constant CFG_KBD_ENABLE  : integer := CONFIG_KBD_ENABLE;
  constant CFG_VGA_ENABLE  : integer := CONFIG_VGA_ENABLE;
  constant CFG_SVGA_ENABLE : integer := CONFIG_SVGA_ENABLE;

-- SPI memory controller
  constant CFG_SPIMCTRL            : integer := CONFIG_SPIMCTRL;
  constant CFG_SPIMCTRL_SDCARD     : integer := CONFIG_SPIMCTRL_SDCARD;
  constant CFG_SPIMCTRL_READCMD    : integer := 16#CONFIG_SPIMCTRL_READCMD#;
  constant CFG_SPIMCTRL_DUMMYBYTE  : integer := CONFIG_SPIMCTRL_DUMMYBYTE;
  constant CFG_SPIMCTRL_DUALOUTPUT : integer := CONFIG_SPIMCTRL_DUALOUTPUT;
  constant CFG_SPIMCTRL_SCALER     : integer := CONFIG_SPIMCTRL_SCALER;
  constant CFG_SPIMCTRL_ASCALER    : integer := CONFIG_SPIMCTRL_ASCALER;
  constant CFG_SPIMCTRL_PWRUPCNT   : integer := CONFIG_SPIMCTRL_PWRUPCNT;
  constant CFG_SPIMCTRL_OFFSET     : integer := 16#CONFIG_SPIMCTRL_OFFSET#;

-- SPI controller
  constant CFG_SPICTRL_ENABLE  : integer := CONFIG_SPICTRL_ENABLE;
  constant CFG_SPICTRL_NUM     : integer := CONFIG_SPICTRL_NUM;
  constant CFG_SPICTRL_SLVS    : integer := CONFIG_SPICTRL_SLVS;
  constant CFG_SPICTRL_FIFO    : integer := CONFIG_SPICTRL_FIFO;
  constant CFG_SPICTRL_SLVREG  : integer := CONFIG_SPICTRL_SLVREG;
  constant CFG_SPICTRL_ODMODE  : integer := CONFIG_SPICTRL_ODMODE;
  constant CFG_SPICTRL_AM      : integer := CONFIG_SPICTRL_AM;
  constant CFG_SPICTRL_ASEL    : integer := CONFIG_SPICTRL_ASEL;
  constant CFG_SPICTRL_TWEN    : integer := CONFIG_SPICTRL_TWEN;
  constant CFG_SPICTRL_MAXWLEN : integer := CONFIG_SPICTRL_MAXWLEN;
  constant CFG_SPICTRL_SYNCRAM : integer := CONFIG_SPICTRL_SYNCRAM;
  constant CFG_SPICTRL_FT      : integer := CONFIG_SPICTRL_FT;

-- GRLIB debugging
  constant CFG_DUART    : integer := CONFIG_DEBUG_UART;

