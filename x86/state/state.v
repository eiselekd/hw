typedef struct packed {
   reg 		    addseg ;     /* non zero if either DS/ES/SS have a non zero base */
   reg 		    prefixseg ;  /* seg prefix override */
   reg [63:0][15:0] r ;
} x86;
