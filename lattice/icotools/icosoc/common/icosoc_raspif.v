
module icosoc_raspif #(
	// number of communication endpoints
	parameter NUM_RECV_EP = 4,
	parameter NUM_SEND_EP = 4,
	parameter NUM_TRIGGERS = 4
) (
	input clk,
	output sync,

	output [NUM_RECV_EP-1:0] recv_valid,
	input  [NUM_RECV_EP-1:0] recv_ready,
	output [       7:0] recv_tdata,

	input  [NUM_SEND_EP-1:0] send_valid,
	output [NUM_SEND_EP-1:0] send_ready,
	input  [       7:0] send_tdata,

	output [NUM_TRIGGERS-1:0] trigger,

	// RasPi Interface: 9 Data Lines (cmds have MSB set)
	inout RASPI_11, RASPI_12, RASPI_15, RASPI_16, RASPI_19, RASPI_21, RASPI_26, RASPI_35, RASPI_36,

	// RasPi Interface: Control Lines
	input RASPI_38, RASPI_40
);
	// All signals with "raspi_" prefix are in the "raspi_clk" clock domain.
	// All other signals are in the "clk" clock domain.

	wire [8:0] raspi_din;
	reg [8:0] raspi_dout;

	wire raspi_dir = RASPI_38;
	wire raspi_clk;

	SB_GB raspi_clock_buffer (
		.USER_SIGNAL_TO_GLOBAL_BUFFER(RASPI_40),
		.GLOBAL_BUFFER_OUTPUT(raspi_clk)
	);

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) raspi_io [8:0] (
		.PACKAGE_PIN({RASPI_11, RASPI_12, RASPI_15, RASPI_16, RASPI_19, RASPI_21, RASPI_26, RASPI_35, RASPI_36}),
		.OUTPUT_ENABLE(!raspi_dir),
		.D_OUT_0(raspi_dout),
		.D_IN_0(raspi_din)
	);


	// system clock side

	function [NUM_SEND_EP-1:0] highest_send_bit;
		input [NUM_SEND_EP-1:0] bits;
		integer i;
		begin
			highest_send_bit = 0;
			for (i = 0; i < NUM_SEND_EP; i = i+1)
				if (bits[i]) highest_send_bit = 1 << i;
		end
	endfunction

	function [7:0] highest_send_bit_index;
		input [NUM_SEND_EP-1:0] bits;
		integer i;
		begin
			highest_send_bit_index = 0;
			for (i = 0; i < NUM_SEND_EP; i = i+1)
				if (bits[i]) highest_send_bit_index = i;
		end
	endfunction

	wire [7:0] recv_epnum, send_epnum;
	wire recv_nempty, send_full;

	assign recv_valid = recv_nempty ? 1 << recv_epnum : 0;
	assign send_ready = highest_send_bit(send_valid) & {NUM_SEND_EP{!send_full}};
	assign send_epnum = highest_send_bit_index(send_valid);

	assign sync = &recv_epnum && &recv_tdata && recv_nempty;
	assign trigger = &recv_epnum && recv_nempty ? 1 << recv_tdata : 0;


	// raspi side

	reg [7:0] raspi_din_ep;
	reg [7:0] raspi_dout_ep = 0;
	wire raspi_recv_nempty;

	wire [15:0] raspi_send_data;
	wire raspi_send_nempty;

	always @* begin
		raspi_dout = raspi_recv_nempty ? 9'h 1fe : 9'h 1ff;
		if (raspi_send_nempty) begin
			if (raspi_dout_ep != raspi_send_data[15:8])
				raspi_dout = {1'b1, raspi_send_data[15:8]};
			else
				raspi_dout = {1'b0, raspi_send_data[ 7:0]};
		end
	end

	always @(posedge raspi_clk) begin
		if (raspi_din[8] && raspi_dir)
			raspi_din_ep <= raspi_din[7:0];
		if (!raspi_dir)
			raspi_dout_ep <= raspi_send_nempty ? raspi_send_data[15:8] : raspi_dout;
	end


	// fifos

	icosoc_crossclkfifo #(
		.WIDTH(16),
		.DEPTH(256)
	) fifo_recv (
		.in_clk(raspi_clk),
		.in_shift(raspi_dir && !raspi_din[8]),
		.in_data({raspi_din_ep, raspi_din[7:0]}),
		.in_nempty(raspi_recv_nempty),

		.out_clk(clk),
		.out_pop(|(recv_valid & recv_ready) || (recv_epnum >= NUM_RECV_EP)),
		.out_data({recv_epnum, recv_tdata}),
		.out_nempty(recv_nempty)
	), fifo_send (
		.in_clk(clk),
		.in_shift(|(send_valid & send_ready)),
		.in_data({send_epnum, send_tdata}),
		.in_full(send_full),

		.out_clk(raspi_clk),
		.out_pop((raspi_dout_ep == raspi_send_data[15:8]) && !raspi_dir),
		.out_data(raspi_send_data),
		.out_nempty(raspi_send_nempty)
	);
endmodule

