`timescale 1ns/1ps

module tb;

    reg          CLK_50M = 0;
    reg          rst_n   = 0;
   
    wire         ck;
    wire         ck_n;
    wire         cke;
    wire         cs_n;
    wire         ras_n;
    wire         cas_n;
    wire         we_n;
    wire  [13:0] a;
    wire   [1:0] ba;
    wire  [15:0] dq;
    wire   [1:0] dqs;
    wire   [1:0] dm;

    mobile_ddr mobile_ddr 
    (
     .Clk      ( ck      ) ,           
     .Clk_n    ( ck_n    ) ,           
     .Cke      ( cke     ) ,           
     .Cs_n     ( cs_n    ) ,           
     .Ras_n    ( ras_n   ) ,           
     .Cas_n    ( cas_n   ) ,           
     .We_n     ( we_n    ) ,           
     .Addr     ( a[12:0] ) ,           
     .Ba       ( ba      ) ,           
     .Dq       ( dq      ) ,           
     .Dqs      ( dqs     ) ,           
     .Dm       ( dm      )  
     );
   
   bemicro_top bemicro_top
   (
    .RAM_A0    ( a[0]   ),
    .RAM_A1    ( a[1]   ),
    .RAM_A2    ( a[2]   ),
    .RAM_A3    ( a[3]   ),
    .RAM_A4    ( a[4]   ),
    .RAM_A5    ( a[5]   ),
    .RAM_A6    ( a[6]   ),
    .RAM_A7    ( a[7]   ),
    .RAM_A8    ( a[8]   ),
    .RAM_A9    ( a[9]   ),
    .RAM_A10   ( a[10]  ),
    .RAM_A11   ( a[11]  ),
    .RAM_A12   ( a[12]  ),
    .RAM_A13   ( a[13]  ),
    .RAM_BA0   ( ba[0]  ),
    .RAM_BA1   ( ba[1]  ),
    
    .RAM_CK_N  ( ck     ),
    .RAM_CK_P  ( ck_n   ),
    .RAM_CKE   ( cke    ),
    .RAM_CS_N  ( cs_n   ),
    .RAM_WS_N  ( we_n   ),
    .RAM_RAS_N ( ras_n  ),
    .RAM_CAS_N ( cas_n  ),
    
    .RAM_D0    ( dq[0]  ),
    .RAM_D1    ( dq[1]  ),
    .RAM_D2    ( dq[2]  ),
    .RAM_D3    ( dq[3]  ),
    .RAM_D4    ( dq[4]  ),
    .RAM_D5    ( dq[5]  ),
    .RAM_D6    ( dq[6]  ),
    .RAM_D7    ( dq[7]  ),
    .RAM_D8    ( dq[8]  ),
    .RAM_D9    ( dq[9]  ),
    .RAM_D10   ( dq[10] ),
    .RAM_D11   ( dq[11] ),
    .RAM_D12   ( dq[12] ),
    .RAM_D13   ( dq[13] ),
    .RAM_D14   ( dq[14] ),
    .RAM_D15   ( dq[15] ),
    
    .RAM_LDM   ( dm[0]  ),
    .RAM_UDM   ( dm[1]  ),
    .RAM_LDQS  ( dqs[0] ),
    .RAM_UDQS  ( dqs[1] ),
    
    .CLK_FPGA_50M 
               ( clk ) 
    );

always
	     #10 CLK_50M <= ~CLK_50M;
   

endmodule // tb
