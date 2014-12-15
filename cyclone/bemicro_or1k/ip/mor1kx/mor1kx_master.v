
module mor1kx_master 
(
   input wire 			 clk,
   input wire			 rst,
   
   output wire [31:0] 		 avm_d_address_o,
   output wire [3:0] 		 avm_d_byteenable_o,
   output wire			 avm_d_read_o,
   input  wire [31:0] 		 avm_d_readdata_i,
   output wire [3:0] 		 avm_d_burstcount_o,
   output wire			 avm_d_write_o,
   output wire [31:0] 		 avm_d_writedata_o,
   input  wire			 avm_d_waitrequest_i,
   input  wire			 avm_d_readdatavalid_i,
   
   output wire [31:0] 		 avm_i_address_o,
   output wire [3:0] 		 avm_i_byteenable_o,
   output wire			 avm_i_read_o,
   input  wire [31:0] 		 avm_i_readdata_i,
   output wire [3:0] 		 avm_i_burstcount_o,
   input  wire			 avm_i_waitrequest_i,
   input  wire			 avm_i_readdatavalid_i
   
);
   
   mor1kx
     #(.BUS_IF_TYPE("AVALON"))
   mor1kx_cpu0
     (
      .clk			(clk),
      .rst			(rst),
      
      .avm_d_address_o          (avm_d_address_o),
      .avm_d_byteenable_o       (avm_d_byteenable_o),
      .avm_d_read_o             (avm_d_read_o),
      .avm_d_readdata_i         (avm_d_readdata_i),
      .avm_d_burstcount_o       (avm_d_burstcount_o),
      .avm_d_write_o            (avm_d_write_o),
      .avm_d_writedata_o        (avm_d_writedata_o),
      .avm_d_waitrequest_i      (avm_d_waitrequest_i),
      .avm_d_readdatavalid_i    (avm_d_readdatavalid_i),
      
      .avm_i_address_o          (avm_i_address_o),
      .avm_i_byteenable_o       (avm_i_byteenable_o),
      .avm_i_read_o             (avm_i_read_o),
      .avm_i_readdata_i         (avm_i_readdata_i),
      .avm_i_burstcount_o       (avm_i_burstcount_o),
      .avm_i_waitrequest_i      (avm_i_waitrequest_i),
      .avm_i_readdatavalid_i    (avm_i_readdatavalid_i)
      
      );
endmodule
