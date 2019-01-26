typedef struct packed {
   reg 		    addseg ;     /* non zero if either DS/ES/SS have a non zero base */
   reg 		    prefixseg ;  /* seg prefix override */
   reg [63:0][15:0] r ;
} x86;

`define b(x) x*8+7:x*8
`define w(x) x*16+15:x*16
`define l(x) x*32+31:x*32

typedef struct packed {
   reg [1:0]   md ;
   reg [2:0]   rg ;
   reg [2:0]   rm ;
} modrm;
