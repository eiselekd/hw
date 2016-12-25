/****************************************************************************************
*
*   Disclaimer   This software code and all associated documentation, comments or other 
*  of Warranty:  information (collectively "Software") is provided "AS IS" without 
*                warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
*                DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
*                TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMIED WARRANTIES 
*                OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
*                WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
*                OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
*                FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
*                THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
*                ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
*                OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
*                ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
*                INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
*                WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
*                OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
*                THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
*                DAMAGES. Because some jurisdictions prohibit the exclusion or 
*                limitation of liability for consequential or incidental damages, the 
*                above limitation may not apply to you.
*
*                Copyright 2006-2008 Micron Technology, Inc. All rights reserved.
*
****************************************************************************************/
// package defines are HC, WP, H4 (default).
 
`ifdef CLASSJ
`define V33
`endif

`ifdef V33
//setup and hold times
//Command, Data, and Address Input
parameter  tCS_min              =          15; // CE# setup time
parameter  tDS_min              =           7; // Data setup time
parameter  tWC_min              =          20; // write cycle time
parameter  tWH_min              =           7; // WE# pulse width HIGH
parameter  tWP_min              =          10; // WE# pulse width
//Normal operation
parameter  tRC_min              =          20; // read cycle time
parameter  tREH_min             =           7; // RE# HIGH hold time
parameter  tRLOH_min            =           5; // RE# LOW to output hold
parameter  tRP_min              =          10; // RE# pulse width
parameter  tWHR_min             =          60; // WE# HIGH to RE# LOW
//EDO cycle time upper bound
parameter  tEDO_RC              =          30;
`define EDO

//Delays
parameter  tREA_max             =          16; // RE# access time
parameter  tCHZ_max             =          30; // CE# HIGH to output High-Z
parameter  tRHZ_max             =         100; // RE# HIGH to output High-Z

//PROGRAM/ERASE Characteristics
parameter  tLBSY_max            =           0; // Busy time for PROGRAM/ERASE on locked block

`else
//### else this is a 1.8v part
//setup and hold times
//Command, Data, and Address Input
parameter  tCS_min              =          20; // CE# setup time
parameter  tDS_min              =          10; // Data setup time
parameter  tWC_min              =          25; // write cycle time
parameter  tWH_min              =          10; // WE# pulse width HIGH
parameter  tWP_min              =          12; // WE# pulse width
//Normal operation
parameter  tRC_min              =          25; // read cycle time
parameter  tREH_min             =          10; // RE# HIGH hold time
parameter  tRLOH_min            =           3; // RE# LOW to output hold
parameter  tRP_min              =          12; // RE# pulse width
parameter  tWHR_min             =          80; // WE# HIGH to RE# LOW
parameter  tEDO_RC              =          30;
`define EDO

//Delays
parameter  tREA_max             =          22; // RE# access time
parameter  tCHZ_max             =          50; // CE# HIGH to output High-Z
parameter  tRHZ_max             =          65; // RE# HIGH to output High-Z

//PROGRAM/ERASE Characteristics
parameter  tLBSY_max            =        3000; // Busy time for PROGRAM/ERASE on locked block (not yet defined in datasheet)
`endif


//setup and hold times
//Command, Data, and Address Input
parameter  tADL_min             =          70; // ALE to data start
parameter  tALH_min             =           5; // ALE hold time
parameter  tALS_min             =          10; // ALE setup time
parameter  tCH_min              =           5; // CE# hold time
parameter  tCLH_min             =           5; // CLE hold time
parameter  tCLS_min             =          10; // CLE setup time
parameter  tDH_min              =           5; // Data hold time
parameter  tWW_min              =         100; // WP# setup time

//Normal operation
parameter  tAR_min              =          10; // ALE to RE# delay
parameter  tCLR_min             =          10; // CLR to RE# delay
parameter  tOH_min              =          15; // CE# HIGH to output hold
parameter  tCOH_min             =     tOH_min; // CE# HIGH to output hold
parameter  tIR_min              =           0; // Output High-Z to RE# LOW
parameter  tRHOH_min            =          15; // RE# HIGH to output hold
parameter  tRHW_min             =         100; // RE# HIGH to WE# LOW
parameter  tRR_min              =          20; // Ready to RE# LOW

//Delays
parameter  tCEA_max             =          25; // CE# access time
parameter  tDCBSYR1_max         =        3000; // Cache busy in page read cache mode (first 31h) (tRCBSY)
parameter  tR_max_no_ecc        =       25000; // Data transfer from Flash array to data register
integer    tR_max               =       25000; // Data transfer from Flash array to data register
parameter  tR_max_ecc           =       70000; // Data transfer from Flash array to data register
parameter  tWB_max              =         100; // WE# HIGH to busy
parameter  tCEA_cache_max       =    tCEA_max; // CE# access time
parameter  tCHZ_cache_max       =    tCHZ_max; // CE# HIGH to output High-Z
parameter  tREA_cache_max       =    tREA_max; // RE# access time

// cache mode ops have special timing
parameter  tWC_cache_min        =          tWC_min; // write cycle time
parameter  tWP_cache_min        =          tWP_min; // WE# pulse width
parameter  tWH_cache_min        =          tWH_min; // WE# pulse width HIGH
parameter  tCLS_cache_min       =          tCLS_min; // CLE setup time
parameter  tCLH_cache_min       =          tCLH_min; // CLE hold time
parameter  tCS_cache_min        =          tCS_min; // CE# setup time
parameter  tCH_cache_min        =          tCH_min; // CE# hold time
parameter  tDS_cache_min        =          tDS_min; // Data setup time
parameter  tDH_cache_min        =          tDH_min; // Data hold time
parameter  tALS_cache_min       =          tALS_min; // ALE setup time
parameter  tALH_cache_min       =          tALH_min; // ALE hold time
parameter  tIR_cache_min        =          tIR_min; // Output High-Z to RE# LOW
parameter  tRC_cache_min        =          tRC_min; // read cycle time
parameter  tREH_cache_min       =          tREH_min; // RE# HIGH hold time
parameter  tRP_cache_min        =          tRP_min; // RE# pulse width
parameter  tWHR_cache_min       =          tWHR_min; // WE# HIGH to RE# LOW
parameter  tWW_cache_min        =          tWW_min; // WP# setup time
parameter  tRLOH_cache_min      =          tRLOH_min; // RE# LOW to output hold

//PROGRAM/ERASE Characteristics
parameter  tBERS_min            =      700000; // BLOCK ERASE operation time
parameter  tBERS_max            =     3000000; // BLOCK ERASE operation time
parameter  tCBSY_min            =        3000; // Busy time for PROGRAM CACHE operation
parameter  tCBSY_max            =      600000; // Busy time for PROGRAM CACHE operation
parameter  tDBSY_min            =         500; // Busy time for TWO-PLANE PROGRAM PAGE operation
parameter  tDBSY_max            =        1000; // Busy time for TWO-PLANE PROGRAM PAGE operation
parameter  tFEAT                =        1000; // Busy time for SET FEATURES and GET FEATURES operations
integer    tOBSY_max            =       30000; // Busy time for OTP DATA PROGRAM if OTP is protected
parameter  tOBSY_max_no_ecc     =       30000; // Busy time for OTP DATA PROGRAM if OTP is protected
parameter  tOBSY_max_ecc        =       50000; // Busy time for OTP DATA PROGRAM if OTP is protected
parameter  tPROG_typ_no_ecc     =      200000; // Busy time for PAGE PROGRAM operation
integer    tPROG_typ            =      200000; // Busy time for PAGE PROGRAM operation
parameter  tPROG_typ_ecc        =      220000; // Busy time for PAGE PROGRAM operation
parameter  tPROG_max            =      600000; // Busy time for PAGE PROGRAM operation
parameter  tRST_read            =        5000; // RESET time issued during READ
parameter  tRST_prog            =       10000; // RESET time issued during PROGRAM
parameter  tRST_erase           =      500000; // RESET time issued during ERASE
parameter  tRST_powerup         =     1000000; // RESET time issued after power-up
parameter  tRST_ready           =        5000; // RESET time issued during idle
parameter  NPP                  =           4; // Number of partial page programs

integer   tLPROG_cache_typ      =      200000; // Prog Page Cache Last Page
`ifdef SHORT_RESET
parameter  tVCC_delay           =         100; // VCC valid to R/B# low valid
parameter  tRB_PU_max           =        1000; // R/B# Power up delay.  
`else  // default
parameter  tVCC_delay           =       10000; // VCC valid to R/B# low valid
parameter  tRB_PU_max           =      100000; // R/B# Power up delay.  
`endif


//unused parameters for this part
parameter  tCLHIO_min           =           0; // Programmable I/O CLE hold time
parameter  tCLSIO_min           =           0; // Programmable I/O CLE setup time
parameter  tDHIO_min            =           0; // Programmable I/O data hold time
parameter  tDSIO_min            =           0; // Programmable I/O data setup time
parameter  tREAIO_max           =           0; // Programmable I/O RE# access time
parameter  tRPIO_min            =           0; // Programmable I/O RE# pulse width
parameter  tWCIO_min            =           0; // Programmable I/O write cycle time
parameter  tWHIO_min            =           0; // Programmable I/O pulse width high
parameter  tWHRIO_min           =           0; // Programmable I/O WE# high to RE# low
parameter  tWPIO_min            =           0; // Programmable I/O WE# pulse width
//not all device datasheets define this parameter
parameter  tCCS_min             =           0; //Column Change Setup: not in datasheet
parameter  tCCS_cache_min       =           0; //Column Change Setup: not in datasheet

//Device memory array configuration parameters
parameter NUM_OTP_ROW       =     30;  // Number of OTP pages
parameter OTP_ADDR_MAX      =   NUM_OTP_ROW+2;
parameter OTP_NPP           =      8;  // Number of Partial Programs in OTP
parameter NUM_BOOT_BLOCKS   =      4;
parameter BOOT_BLOCK_BITS   =      2;
parameter BLCK_BITS         =     12;   
parameter NUM_BLCK          =      (1 << BLCK_BITS) -1;  // block limit 
`ifdef x16
    parameter DQ_BITS       =     16;
    parameter COL_BITS      =     11;
    parameter COL_CNT_BITS  =     11;  // NUM_COL rounded up
    parameter NUM_COL       =   1056; //1024 + 32 spare words
`else // x8
    parameter DQ_BITS       =      8;
    parameter COL_BITS      =     12;
    parameter COL_CNT_BITS  =     12;  // NUM_COL rounded up
    parameter NUM_COL       =   2112; //2048 + 64 spare bytes
`endif

`ifdef CLASSJ
    parameter ROW_BITS      =     19;
    parameter LUN_BITS      =      1;
`else `ifdef CLASSD
    parameter ROW_BITS      =     19;
    parameter LUN_BITS      =      1;
`else // CLASSB
    parameter ROW_BITS      =     18;
    parameter LUN_BITS      =      0;
`endif `endif

`ifdef FullMem   // Only define this if you require the full memory size.
    parameter NUM_ROW       = 262144;  // PagesXBlocks = 64x4096  for 4G
`else
    // set these lower than real value to speed up sim load and run time
    parameter NUM_ROW       =    256;  // smaller value for fast sim load
`endif
parameter NUM_PLANES        =      2;

parameter BPC_MAX           = 3'b001;
parameter BPC               = 3'b001;

parameter PAGE_BITS         =      6;  // 2^6=64
parameter NUM_PAGE          =     64;
parameter PAGE_SIZE         =    NUM_COL*BPC_MAX*DQ_BITS;

//Read ID values [ 0x2c, 0xac, 0x90, 0x15, 0x56, 0x00, 0x00, 0x00 ]
parameter NUM_ID_BYTES      =      5;
parameter READ_ID_BYTE0     =  8'h2c;   // Micron Manufacturer ID

`ifdef CLASSJ
    parameter READ_ID_BYTE1 = 8'hD3;
`else `ifdef CLASSD
    `ifdef V33
        `ifdef x16 
	    parameter READ_ID_BYTE1 = 8'hC3;
        `else // x8
	    parameter READ_ID_BYTE1 = 8'hD3;
        `endif
    `else
        `ifdef x16
	    parameter READ_ID_BYTE1 = 8'hB3;
        `else // x8
	    parameter READ_ID_BYTE1 = 8'hA3;
        `endif
    `endif
`else // CLASSB
    `ifdef V33
        `ifdef x16 
	    parameter READ_ID_BYTE1 = 8'hCC;
        `else // x8
	    parameter READ_ID_BYTE1 = 8'hDC;
        `endif
    `else
        `ifdef x16
	    parameter READ_ID_BYTE1 = 8'hBC;
        `else // x8
	    parameter READ_ID_BYTE1 = 8'hAC;
        `endif
    `endif
`endif `endif

`ifdef CLASSJ
    parameter READ_ID_BYTE2     =  8'hD1;
`else `ifdef CLASSD
    parameter READ_ID_BYTE2     =  8'hD1;
`else // CLASSB
    parameter READ_ID_BYTE2     =  8'h90;
`endif `endif

`ifdef V33
    `ifdef x16
    	parameter READ_ID_BYTE3 = 8'hD5;
    `else // x8
    	parameter READ_ID_BYTE3 = 8'h95;
    `endif
`else
    `ifdef x16
        parameter READ_ID_BYTE3 =  8'h55;
    `else // x8
        parameter READ_ID_BYTE3 =  8'h15;
    `endif
`endif

`ifdef CLASSJ
integer READ_ID_BYTE4		=  8'h5A;
parameter READ_ID_BYTE4_no_ecc	=  8'h5A;
parameter READ_ID_BYTE4_ecc	=  8'hDA;
`else `ifdef CLASSD
integer READ_ID_BYTE4		=  8'h5A;
parameter READ_ID_BYTE4_no_ecc	=  8'h5A;
parameter READ_ID_BYTE4_ecc	=  8'hDA;
`else // CLASSB
integer READ_ID_BYTE4		=  8'h56;
parameter READ_ID_BYTE4_no_ecc	=  8'h56;
parameter READ_ID_BYTE4_ecc	=  8'hD6;
`endif `endif


`ifdef V33
parameter FEATURE_SET = 16'b0010111001111011;
`else
parameter FEATURE_SET = 16'b0010111011111011;
`endif
//                    used--||||||||||||||||--basic NAND commands
//                     used--||||||||||||||--new commands (page rd cache commands)
//           boot block lock--||||||||||||--read ID2
//                       used--||||||||||--read unique
//                 page unlock--||||||||--OTP commands
//                     ONFI_OTP--||||||--2plane commands
//                      features--||||--ONFI 
//       drive strength(non-ONFI)--||--block lock

parameter FEATURE_SET2 = 16'b0000000000000001;
//                   unused--||||||||||||||||--ECC timing
//                    unused--||||||||||||||--unused
//                     unused--||||||||||||--unused
//                      unused--||||||||||--unused
//                       unused--||||||||--unused
//                        unused--||||||--unused
//                         unused--||||--unused
//                          unused--||--unused

parameter DRIVESTR_EN = 3'h0; // supports feature address 80h only
parameter NOONFIRDCACHERANDEN = 3'h0; // non-onfi read page cache random enable (special case)
//-------------------------------------------
//   ONFI Setup
//-------------------------------------------
//need to keep this in params file since ever NAND device will have different values
reg [DQ_BITS -1 : 0]        onfi_params_array [NUM_COL-1 : 0]; // packed array
reg [PAGE_SIZE -1 : 0]      onfi_params_array_unpacked;

task setup_params_array;
    integer k;
    reg [PAGE_SIZE -1 : 0]      mask;
    begin
    // Here we set the values of the read-only ONFI parameters.
    // These are defined by the ONFI spec
    // and are the default power-on values for the ONFI FEATURES supported by this device.
    //-----------------------------------
    //Parameter page signature
    onfi_params_array[0] = 8'h4F; // 'O'
    onfi_params_array[1] = 8'h4E; // 'N'
    onfi_params_array[2] = 8'h46; // 'F'
    onfi_params_array[3] = 8'h49; // 'I'
    //ONFI revision number
    onfi_params_array[4] = 8'h02; // ONFI 1.0 compliant
    onfi_params_array[5] = 8'h00;
    //Features supported
    `ifdef CLASSJ
	onfi_params_array[6] = 8'h1A;
    `else `ifdef CLASSD
        `ifdef x16
	    onfi_params_array[6] = 8'h1B;
        `else // x8
	    onfi_params_array[6] = 8'h1A;
        `endif
    `else // CLASSB
        `ifdef x16
	    onfi_params_array[6] = 8'h19;
        `else // x8
	    onfi_params_array[6] = 8'h18;
        `endif
    `endif `endif
    onfi_params_array[7] = 8'h00;
    //optional command supported
    onfi_params_array[8] = 8'h3F;
    onfi_params_array[9] = 8'h00;
    //Reserved
    for (k=10; k<=31 ; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    //Manufacturer ID
    onfi_params_array[32] = 8'h4D; //M
    onfi_params_array[33] = 8'h49; //I
    onfi_params_array[34] = 8'h43; //C
    onfi_params_array[35] = 8'h52; //R
    onfi_params_array[36] = 8'h4F; //O
    onfi_params_array[37] = 8'h4E; //N
    onfi_params_array[38] = 8'h20;
    onfi_params_array[39] = 8'h20;
    onfi_params_array[40] = 8'h20;
    onfi_params_array[41] = 8'h20;
    onfi_params_array[42] = 8'h20;
    onfi_params_array[43] = 8'h20;
    
    //Device model
    onfi_params_array[44] = 8'h4D; //M
    onfi_params_array[45] = 8'h54; //T
    onfi_params_array[46] = 8'h32; //2
    onfi_params_array[47] = 8'h39; //9
    onfi_params_array[48] = 8'h46; //F
    
`ifdef CLASSJ
	    onfi_params_array[49] = 8'h31; // 1
	    onfi_params_array[50] = 8'h36; // 6
	    onfi_params_array[51] = 8'h47; // G
	    onfi_params_array[52] = 8'h30; // 0
	    onfi_params_array[53] = 8'h38; // 8
	    onfi_params_array[54] = 8'h41; // A
	    onfi_params_array[55] = 8'h4A; // J
	    onfi_params_array[56] = 8'h41; // A
	    onfi_params_array[57] = 8'h44; // D
	    onfi_params_array[58] = 8'h41; // A
	    onfi_params_array[59] = 8'h57; // W
	    onfi_params_array[60] = 8'h50; // P
`else `ifdef CLASSD
    `ifdef V33
        `ifdef x16
	    onfi_params_array[49] = 8'h38; // 8
	    onfi_params_array[50] = 8'h47; // G
	    onfi_params_array[51] = 8'h31; // 1
	    onfi_params_array[52] = 8'h36; // 6
	    onfi_params_array[53] = 8'h41; // A
	    onfi_params_array[54] = 8'h44; // D
	    onfi_params_array[55] = 8'h41; // A
	    onfi_params_array[56] = 8'h44; // D
	    onfi_params_array[57] = 8'h41; // A
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h34; // 4
	    onfi_params_array[60] = 8'h20;
        `else // x8
	    onfi_params_array[49] = 8'h38; // 8
	    onfi_params_array[50] = 8'h47; // G
	    onfi_params_array[51] = 8'h30; // 0
	    onfi_params_array[52] = 8'h38; // 8
	    onfi_params_array[53] = 8'h41; // A
	    onfi_params_array[54] = 8'h44; // D
	    onfi_params_array[55] = 8'h41; // A
	    onfi_params_array[56] = 8'h44; // D
	    onfi_params_array[57] = 8'h41; // A
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h34; // 4
	    onfi_params_array[60] = 8'h20;
        `endif
    `else // v18
        `ifdef x16
	    onfi_params_array[49] = 8'h38; // 8
	    onfi_params_array[50] = 8'h47; // G
	    onfi_params_array[51] = 8'h31; // 1
	    onfi_params_array[52] = 8'h36; // 6
	    onfi_params_array[53] = 8'h41; // A
	    onfi_params_array[54] = 8'h44; // D
	    onfi_params_array[55] = 8'h42; // B
	    onfi_params_array[56] = 8'h44; // D
	    onfi_params_array[57] = 8'h41; // A
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h34; // 4
	    onfi_params_array[60] = 8'h20;
        `else // x8
	    onfi_params_array[49] = 8'h38; // 8
	    onfi_params_array[50] = 8'h47; // G
	    onfi_params_array[51] = 8'h30; // 0
	    onfi_params_array[52] = 8'h38; // 8
	    onfi_params_array[53] = 8'h41; // A
	    onfi_params_array[54] = 8'h44; // D
	    onfi_params_array[55] = 8'h42; // B
	    onfi_params_array[56] = 8'h44; // D
	    onfi_params_array[57] = 8'h41; // A
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h34; // 4
	    onfi_params_array[60] = 8'h20;
        `endif
    `endif
`else // DEFAULT = CLASSB
    `ifdef V33
        `ifdef x16
	    onfi_params_array[49] = 8'h34; // 4
	    onfi_params_array[50] = 8'h47; // G
	    onfi_params_array[51] = 8'h31; // 1
	    onfi_params_array[52] = 8'h36; // 6
	    onfi_params_array[53] = 8'h41; // A
	    onfi_params_array[54] = 8'h42; // B
	    onfi_params_array[55] = 8'h41; // A
	    onfi_params_array[56] = 8'h44; // D
	    onfi_params_array[57] = 8'h41; // A
            `ifdef WP
	    onfi_params_array[58] = 8'h57; // W
	    onfi_params_array[59] = 8'h50; // P
            `else
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h34; // 4
            `endif
	    onfi_params_array[60] = 8'h20;
        `else // x8
	    onfi_params_array[49] = 8'h34; // 4
	    onfi_params_array[50] = 8'h47; // G
	    onfi_params_array[51] = 8'h30; // 0
	    onfi_params_array[52] = 8'h38; // 8
	    onfi_params_array[53] = 8'h41; // A
	    onfi_params_array[54] = 8'h42; // B
	    onfi_params_array[55] = 8'h41; // A
	    onfi_params_array[56] = 8'h44; // D
	    onfi_params_array[57] = 8'h41; // A
            `ifdef WP
	    onfi_params_array[58] = 8'h57; // W
	    onfi_params_array[59] = 8'h50; // P
            `else
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h34; // 4
            `endif
	    onfi_params_array[60] = 8'h20;
        `endif
    `else // v18
        `ifdef x16
	    onfi_params_array[49] = 8'h34; // 4
	    onfi_params_array[50] = 8'h47; // G
	    onfi_params_array[51] = 8'h31; // 1
	    onfi_params_array[52] = 8'h36; // 6
	    onfi_params_array[53] = 8'h41; // A
	    onfi_params_array[54] = 8'h42; // B
	    onfi_params_array[55] = 8'h42; // B
	    onfi_params_array[56] = 8'h44; // D
	    onfi_params_array[57] = 8'h41; // A
            `ifdef HC
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h43; // C
            `else
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h34; // 4
            `endif
	    onfi_params_array[60] = 8'h20;
        `else // x8
	    onfi_params_array[49] = 8'h34; // 4
	    onfi_params_array[50] = 8'h47; // G
	    onfi_params_array[51] = 8'h30; // 0
	    onfi_params_array[52] = 8'h38; // 8
	    onfi_params_array[53] = 8'h41; // A
	    onfi_params_array[54] = 8'h42; // B
	    onfi_params_array[55] = 8'h42; // B
	    onfi_params_array[56] = 8'h44; // D
	    onfi_params_array[57] = 8'h41; // A
            `ifdef HC
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h43; // C
            `else
	    onfi_params_array[58] = 8'h48; // H
	    onfi_params_array[59] = 8'h34; // 4
            `endif
	    onfi_params_array[60] = 8'h20;
        `endif
    `endif
`endif `endif
    onfi_params_array[61] = 8'h20;
    onfi_params_array[62] = 8'h20;
    onfi_params_array[63] = 8'h20;

    //manufacturer ID
    onfi_params_array[64] = 8'h2C;
    //Date code
    onfi_params_array[65] = 8'h00; 
    onfi_params_array[66] = 8'h00; 
    //reserved
    for (k=67; k<=79 ; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    //Number of data bytes per page
    onfi_params_array[80] = 8'h00;
    onfi_params_array[81] = 8'h08;
    onfi_params_array[82] = 8'h00;
    onfi_params_array[83] = 8'h00;
    //Number of spare bytes per page        
    onfi_params_array[84] = 8'h40;
    onfi_params_array[85] = 8'h00;
    //Number of data bytes per partial page
    onfi_params_array[86] = 8'h00;    
    onfi_params_array[87] = 8'h02;    
    onfi_params_array[88] = 8'h00;    
    onfi_params_array[89] = 8'h00;    
    //Number of spare bytes per partial page
    onfi_params_array[90] = 8'h10;
    onfi_params_array[91] = 8'h00;
    //Number of pages per block
    onfi_params_array[92] = 8'h40;
    onfi_params_array[93] = 8'h00;
    onfi_params_array[94] = 8'h00;
    onfi_params_array[95] = 8'h00;
    //Number of blocks per unit
    onfi_params_array[96] = 8'h00;
    onfi_params_array[97] = 8'h10;
    onfi_params_array[98] = 8'h00;
    onfi_params_array[99] = 8'h00;
    //Number of units
    `ifdef CLASSJ
	onfi_params_array[100] = 8'h04;
    `else `ifdef CLASSD
	onfi_params_array[100] = 8'h02;
    `else // CLASSB
	onfi_params_array[100] = 8'h01;
    `endif `endif
    //Number of address cycles
    onfi_params_array[101] = 8'h23;
    //Number of bits per cell
    onfi_params_array[102] = 8'h01;
    //Bad blocks maximum per unit
    onfi_params_array[103] = 8'h50;
    onfi_params_array[104] = 8'h00;
    //Block endurance
    onfi_params_array[105] = 8'h01;
    onfi_params_array[106] = 8'h05;
    //Guaranteed valid blocks at beginning of target
    onfi_params_array[107] = 8'h01;
    //Block endurance for guaranteed valid blocks
    onfi_params_array[108] = 8'h00;
    onfi_params_array[109] = 8'h00;
    //Number of program per page
    onfi_params_array[110] = 8'h04;
    //Partial programming attributes
    onfi_params_array[111] = 8'h00;
    //Number of ECC bits
    onfi_params_array[112] = 8'h04;
    //Number of interleaved address bits
    onfi_params_array[113] = 8'h01;
    //Interleaved operation attributes
    onfi_params_array[114] = 8'h0E;
    //reserved
    for (k=115; k<=127 ; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    //IO pin capacitance
    `ifdef CLASSJ
	onfi_params_array[128] = 8'h28;
    `else `ifdef CLASSD
	onfi_params_array[128] = 8'h14;
    `else // CLASSB
	onfi_params_array[128] = 8'h0A;
    `endif `endif
    //Timing mode support
    `ifdef V33
	onfi_params_array[129] = 8'h3F;
	onfi_params_array[130] = 8'h00;
    `else
	onfi_params_array[129] = 8'h1F;
	onfi_params_array[130] = 8'h00;
    `endif
    //Program cache timing mode support
    `ifdef V33
	onfi_params_array[131] = 8'h3F;
	onfi_params_array[132] = 8'h00;
    `else
	onfi_params_array[131] = 8'h1F;
	onfi_params_array[132] = 8'h00;
    `endif
    //tPROG max page program time
    onfi_params_array[133] = 8'h58;
    onfi_params_array[134] = 8'h02;
    //tBERS max block erase time
    onfi_params_array[135] = 8'hB8;
    onfi_params_array[136] = 8'h0B;
    //tR max page read time        
    onfi_params_array[137] = 8'h19;
    onfi_params_array[138] = 8'h00;
    //tCCS min change column setup time (same as tWHR)
    onfi_params_array[139] = 8'h64;
    onfi_params_array[140] = 8'h00;
    //reserved
    for (k=141; k<=163; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    //Vendor-specific revision number    
    onfi_params_array[164] = 8'h01;
    onfi_params_array[165] = 8'h00;
    //vendor-specific
	onfi_params_array[166] = 8'h01;
	onfi_params_array[167] = 8'h00;
	onfi_params_array[168] = 8'h00;
	onfi_params_array[169] = 8'h02;
	onfi_params_array[170] = 8'h04;
	onfi_params_array[171] = 8'h80;
	onfi_params_array[172] = 8'h01;
	onfi_params_array[173] = 8'h81;
	onfi_params_array[174] = 8'h04;
	onfi_params_array[175] = 8'h01;
	onfi_params_array[176] = 8'h02;
	onfi_params_array[177] = 8'h01;
	onfi_params_array[178] = 8'h0A;
	onfi_params_array[179] = 8'h00;
    for (k=180; k<=253; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    //Integrity CRC
`ifdef CLASSJ
	    onfi_params_array[254] = 8'hAA;
	    onfi_params_array[255] = 8'h3E;
`else `ifdef CLASSD
    `ifdef V33
        `ifdef x16
	    onfi_params_array[254] = 8'h05;
	    onfi_params_array[255] = 8'h9F;
        `else // x8
	    onfi_params_array[254] = 8'h23;
	    onfi_params_array[255] = 8'h5A;
        `endif
    `else // v18
        `ifdef x16
	    onfi_params_array[254] = 8'hBE;
	    onfi_params_array[255] = 8'h0C;
        `else // x8
	    onfi_params_array[254] = 8'h98;
	    onfi_params_array[255] = 8'hC9;
        `endif
    `endif
`else // DEFAULT = CLASSB
    `ifdef V33
        `ifdef x16
            `ifdef WP
	    onfi_params_array[254] = 8'hAA;
	    onfi_params_array[255] = 8'h85;
            `else // H4
	    onfi_params_array[254] = 8'h00;
	    onfi_params_array[255] = 8'h3E;
            `endif
        `else // x8
            `ifdef WP
	    onfi_params_array[254] = 8'h8C;
	    onfi_params_array[255] = 8'h40;
            `else // H4
	    onfi_params_array[254] = 8'h26;
	    onfi_params_array[255] = 8'hFB;
            `endif
        `endif
    `else // v18
        `ifdef x16
            `ifdef HC
	    onfi_params_array[254] = 8'h10;
	    onfi_params_array[255] = 8'hF0;
            `else // H4
	    onfi_params_array[254] = 8'hBB;
	    onfi_params_array[255] = 8'hAD;
            `endif
        `else // x8
            `ifdef HC
	    onfi_params_array[254] = 8'h36;
	    onfi_params_array[255] = 8'h35;
            `else // H4
	    onfi_params_array[254] = 8'h9D;
	    onfi_params_array[255] = 8'h68;
            `endif
        `endif
    `endif
`endif `endif

    onfi_params_array_unpacked =0;
    for (k=0; k<=255; k=k+1) begin
        mask = ({8{1'b1}} << (k*8)); // shifting left zero-fills
        //mask clears onfi params array unpacked slice so can or in onfi_params_array[k] byte
        onfi_params_array_unpacked = (onfi_params_array_unpacked & ~mask) | (onfi_params_array[k]<<(k*8)); // unpacking array
    end

    // onfi params array repeats for each 256 bytes up to 768, than all FFs to last column.  
    onfi_params_array_unpacked[0512*8-1:0256*8] = onfi_params_array_unpacked[0256*8-1:0000];
    onfi_params_array_unpacked[0768*8-1:0512*8] = onfi_params_array_unpacked[0256*8-1:0000];
    onfi_params_array_unpacked[NUM_COL*8-1:768*8] = {(NUM_COL-768){8'hFF}};
    end
endtask


//----------------------------------------------------*
//device specific defines that must be set
//----------------------------------------------------*
//`define KEEP_LOCKTIGHT_AFTER_WPN
//----------------------------------------------------*
//device package/die configuration parameters
//----------------------------------------------------*
//-------------------------------------------
//   Multiple Die Setup
//-------------------------------------------
`ifdef CLASSJ
    `define NUM_DIE4
    parameter NUM_DIE   =   4;
    parameter NUM_CE    =   2;
    `define DIES4
`else `ifdef CLASSD
    `define NUM_DIE2
    parameter NUM_DIE   =   2;
    parameter NUM_CE    =   1;
    `define DIES2
`else  // DEFAULT = CLASSB
    parameter NUM_DIE   =   1;
    parameter NUM_CE    =   1;
`endif `endif
parameter async_only_n = 1'b0;

//-----------------------------------------------------------------
// FUNCTION : check_feat_addr (addr)
// verifies feature address is valid for this part.
//-----------------------------------------------------------------
function check_feat_addr;
input [07:00] id_reg_addr;
input [00:00] nand_mode  ;
begin
    check_feat_addr = 0;
    case (id_reg_addr)
        8'h01, 8'h80, 8'h81, 8'h90 : check_feat_addr = 1;
    endcase
end
endfunction

reg [(4*DQ_BITS)-1 : 0]         onfi_features [0 : 255];
//----------------------------------------------------------------------
// TASK : init_onfi_params
//Assigns the read-only ONFI parameters (for devices with ONFI support)
//----------------------------------------------------------------------
task init_onfi_params;
begin
    //Supported ONFI feature addresses and parameter initialization
    //These are used in the GET FEATURES and SET FEATURES commands
    // Read Features section has read data output assignments. 
    onfi_features[8'h01] = 0;
    onfi_features[8'h80] = 0;
    onfi_features[8'h81] = 0;
    onfi_features[8'h90] = 0;

    setup_params_array;  // ONFI parameter page
end
endtask

//----------------------------------------------------------------------
// TASK : update_feat_gen
//----------------------------------------------------------------------
task update_feat_gen;
input gen_in; 
begin
    if(gen_in) begin 
        tR_max = tR_max_ecc;
        tPROG_typ = tPROG_typ_ecc;
	tOBSY_max = tOBSY_max_ecc;
        tLPROG_cache_typ     =   tPROG_typ_ecc;
	READ_ID_BYTE4 = READ_ID_BYTE4_ecc;
    end else begin
        tR_max = tR_max_no_ecc;
        tPROG_typ = tPROG_typ_no_ecc;
	tOBSY_max = tOBSY_max_no_ecc;
        tLPROG_cache_typ     =   tPROG_typ_no_ecc;
	READ_ID_BYTE4 = READ_ID_BYTE4_no_ecc;
    end
end
endtask
