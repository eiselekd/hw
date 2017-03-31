//
//    Copyright (c) 2015 Jan Adelsbach <jan@janadelsbach.com>.  
//    All Rights Reserved.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

`define MC14500B_OP_NOPO 4'b0000
`define MC14500B_OP_LD   4'b0001
`define MC14500B_OP_LDC  4'b0010
`define MC14500B_OP_AND  4'b0011
`define MC14500B_OP_ANDC 4'b0100
`define MC14500B_OP_OR   4'b0101
`define MC14500B_OP_ORC  4'b0110
`define MC14500B_OP_XNOR 4'b0111
`define MC14500B_OP_STO  4'b1000
`define MC14500B_OP_STOC 4'b1001
`define MC14500B_OP_IEN  4'b1010
`define MC14500B_OP_OEN  4'b1011
`define MC14500B_OP_JMP  4'b1100
`define MC14500B_OP_RTN  4'b1101
`define MC14500B_OP_SKZ  4'b1110
`define MC14500B_OP_NOPF 4'b1111

module mc14500b(i_clk, i_rst, i_op,
		io_d,
		o_wr, o_jmp, o_rtn, o_flgf, o_flgo);

   input       i_clk;
   input       i_rst;
   input [3:0] i_op;
   
   inout       io_d;

   output      o_wr;
   output      o_jmp;
   output      o_rtn;
   output      o_flgf;
   output      o_flgo;
   
   reg 	       r_ien;
   reg 	       r_oen;
   reg 	       r_skp;
   reg 	       r_rr;

   wire        w_d;
   assign w_d = io_d & r_ien;
   
   assign o_jmp  = (i_op == `MC14500B_OP_JMP  & ~r_skp);
   assign o_rtn  = (i_op == `MC14500B_OP_RTN  & ~r_skp);
   assign o_flgf = (i_op == `MC14500B_OP_NOPF & ~r_skp);
   assign o_flgo = (i_op == `MC14500B_OP_NOPO & ~r_skp);

   assign o_wr = (i_op == `MC14500B_OP_STO |
		  i_op == `MC14500B_OP_STOC) & ~r_skp & r_oen;
   
   assign io_d = (i_op == `MC14500B_OP_STO)  ? r_rr :
		 (i_op == `MC14500B_OP_STOC) ? ~r_rr : 1'bz;
   
   
   always @(posedge i_clk) begin
      if(i_rst) begin
	 r_ien <= 0;
	 r_oen <= 0;
	 r_skp <= 0;
	 r_rr  <= 0;
      end
      else begin
         if(~r_skp) begin
	    case(i_op)
	      `MC14500B_OP_LD:
		r_rr <= w_d;
	      `MC14500B_OP_LDC:
		r_rr <= ~w_d;
	      `MC14500B_OP_AND:
		r_rr = r_rr & w_d;
	      `MC14500B_OP_ANDC:
		r_rr = r_rr & ~w_d;
	      `MC14500B_OP_OR:
		r_rr = r_rr | w_d;
	      `MC14500B_OP_ORC:
		r_rr = r_rr | ~w_d;
	      `MC14500B_OP_XNOR:
		r_rr = r_rr ^ ~w_d;
	      `MC14500B_OP_IEN:
		r_ien <= w_d;
	      `MC14500B_OP_OEN:
		r_oen <= w_d;
	      `MC14500B_OP_SKZ:
		r_skp <= ~(|r_rr);
	    endcase // case (i_op)
	 end
	 else
           r_skp = 1'b0;
      end
   end
   
endmodule
