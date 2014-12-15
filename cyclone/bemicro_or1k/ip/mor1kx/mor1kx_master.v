module mor1kx_master (
	clk,
	reset,

	// master inputs and outputs
	master_address,
	master_read,
	master_write,
	master_byteenable,
	master_readdata,
	master_readdatavalid,
	master_writedata,
	master_burstcount,
	master_waitrequest
);

	parameter DATA_WIDTH = 32;
	parameter FIFO_DEPTH = 32;
	parameter FIFO_DEPTH_LOG2 = 5;
	parameter ADDRESS_WIDTH = 32;
	parameter BURST_CAPABLE = 0;                              // 1 to enable burst, 0 to disable it
	parameter MAXIMUM_BURST_COUNT = 2;
	parameter BURST_COUNT_WIDTH = 2;

	input clk;
	input reset;
	
	// master inputs and outputs
	output wire [ADDRESS_WIDTH-1:0] master_address;
	output wire master_read;                                  // for read master
	output wire master_write;                                 // for write master
	output wire [(DATA_WIDTH/8)-1:0] master_byteenable;
	input [DATA_WIDTH-1:0] master_readdata;                   // for read master
	input master_readdatavalid;                               // for read master
	output wire [DATA_WIDTH-1:0] master_writedata;            // for write master
	output wire [BURST_COUNT_WIDTH-1:0] master_burstcount;    // for bursting read and write masters
	input master_waitrequest;



endmodule
