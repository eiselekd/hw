
module icosoc_crossclkfifo #(
	parameter WIDTH = 8,
	parameter DEPTH = 16
) (
	input                  in_clk,
	input                  in_shift,
	input      [WIDTH-1:0] in_data,
	output reg             in_full,
	output reg             in_nempty,

	input                  out_clk,
	input                  out_pop,
	output     [WIDTH-1:0] out_data,
	output reg             out_nempty
);
	localparam integer ABITS = $clog2(DEPTH);

	initial begin
		in_full = 0;
		in_nempty = 0;
		out_nempty = 0;
	end

	function [ABITS-1:0] bin2gray(input [ABITS-1:0] in);
		begin
			bin2gray = in ^ (in >> 1);
		end
	endfunction

	function [ABITS-1:0] gray2bin(input [ABITS-1:0] in);
		begin
			gray2bin = in;
			// Assuming ABITS is less or equal 32
			gray2bin = gray2bin ^ (gray2bin >> 16);
			gray2bin = gray2bin ^ (gray2bin >> 8);
			gray2bin = gray2bin ^ (gray2bin >> 4);
			gray2bin = gray2bin ^ (gray2bin >> 2);
			gray2bin = gray2bin ^ (gray2bin >> 1);
		end
	endfunction

	reg [ABITS-1:0] in_ipos = 0, in_opos = 0;
	reg [ABITS-1:0] out_opos = 0, out_ipos = 0;

	reg [WIDTH-1:0] memory [0:DEPTH-1];

	// input side of fifo

	wire [ABITS-1:0] next_ipos = in_ipos == DEPTH-1 ? 0 : in_ipos + 1;
	wire [ABITS-1:0] next_next_ipos = next_ipos == DEPTH-1 ? 0 : next_ipos + 1;

	always @(posedge in_clk) begin
		if (in_shift && !in_full) begin
			memory[in_ipos] <= in_data;
			in_full <= next_next_ipos == in_opos;
			in_nempty <= 1;
			in_ipos <= next_ipos;
		end else begin
			in_full <= next_ipos == in_opos;
			in_nempty <= in_ipos != in_opos;
		end
	end

	// output side of fifo

	wire [ABITS-1:0] next_opos = out_opos == DEPTH-1 ? 0 : out_opos + 1;
	reg [WIDTH-1:0] out_data_d;

	always @(posedge out_clk) begin
		if (out_pop && out_nempty) begin
			out_data_d <= memory[next_opos];
			out_nempty <= next_opos != out_ipos;
			out_opos <= next_opos;
		end else begin
			out_data_d <= memory[out_opos];
			out_nempty <= out_opos != out_ipos;
		end
	end

	assign out_data = out_nempty ? out_data_d : 0;

	// clock domain crossing of ipos

	reg [ABITS-1:0] in_ipos_gray = 0;
	reg [ABITS-1:0] out_ipos_gray_2 = 0;
	reg [ABITS-1:0] out_ipos_gray_1 = 0;
	reg [ABITS-1:0] out_ipos_gray_0 = 0;

	always @(posedge in_clk) begin
		in_ipos_gray <= bin2gray(in_ipos);
	end

	always @(posedge out_clk) begin
		out_ipos_gray_2 <= in_ipos_gray;
		out_ipos_gray_1 <= out_ipos_gray_2;
		out_ipos_gray_0 <= out_ipos_gray_1;
		out_ipos <= gray2bin(out_ipos_gray_0);
	end


	// clock domain crossing of opos

	reg [ABITS-1:0] out_opos_gray = 0;
	reg [ABITS-1:0] in_opos_gray_2 = 0;
	reg [ABITS-1:0] in_opos_gray_1 = 0;
	reg [ABITS-1:0] in_opos_gray_0 = 0;

	always @(posedge out_clk) begin
		out_opos_gray <= bin2gray(out_opos);
	end

	always @(posedge in_clk) begin
		in_opos_gray_2 <= out_opos_gray;
		in_opos_gray_1 <= in_opos_gray_2;
		in_opos_gray_0 <= in_opos_gray_1;
		in_opos <= gray2bin(in_opos_gray_0);
	end
endmodule

