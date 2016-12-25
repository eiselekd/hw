module up_counter (
	cnt,
	enable,
	clk,
	reset
		   );

   output [7:0] cnt;

   input 	enable, clk, reset;

   reg [7:0] 	cnt;

always @(posedge clk)
if (reset) begin
   cnt <= 8'b0;

end else if (enable) begin
   cnt <= cnt + 1;
end

endmodule
 
