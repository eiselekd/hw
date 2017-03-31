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

module mc14512(dis, inh, a, x, q);
	input dis;
	input inh;
	input [2:0] a;
	input [7:0] x;
	output q;

	assign z = (inh & ~dis) ? 1'b0 :
               dis ? 1'bz : x[a];
endmodule
