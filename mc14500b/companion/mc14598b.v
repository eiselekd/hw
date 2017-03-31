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

module mc14598b(rst, dat, stb, oe, a, q);
	input rst;
	input dat;
	input stb;
	input oe;
	input [2:0] a;
	output [7:0] q;

	reg [7:0] r_q;

	assign q = (~oe) ? r_q : 8'bz;

	always @(rst or stb) begin
		if(~rst)
			r_q <= 0;
		else if(stb)
			r_q[a] <= dat;
	end
endmodule  
