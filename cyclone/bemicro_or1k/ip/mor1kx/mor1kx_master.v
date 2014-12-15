
module mor1kx_master 
  (
   clk,
   rst,
   
   avm_d_address_o,
   avm_d_byteenable_o,
   avm_d_read_o,
   avm_d_readdata_i,
   avm_d_burstcount_o,
   avm_d_write_o,
   avm_d_writedata_o,
   avm_d_waitrequest_i,
   avm_d_readdatavalid_i,
   
   avm_i_address_o,
   avm_i_byteenable_o,
   avm_i_read_o,
   avm_i_readdata_i,
   avm_i_burstcount_o,
   avm_i_waitrequest_i,
   avm_i_readdatavalid_i
   
);
   
   input 			      clk;
   input 			      reset;
   
   output [31:0] 		      avm_d_address_o;
   output [3:0] 		      avm_d_byteenable_o;
   output 			      avm_d_read_o;
   input [31:0] 		      avm_d_readdata_i;
   output [3:0] 		      avm_d_burstcount_o;
   output 			      avm_d_write_o;
   output [31:0] 		      avm_d_writedata_o;
   input 			      avm_d_waitrequest_i;
   input 			      avm_d_readdatavalid_i;
   
   output [31:0] 		      avm_i_address_o;
   output [3:0] 		      avm_i_byteenable_o;
   output 			      avm_i_read_o;
   input [31:0] 		      avm_i_readdata_i;
   output [3:0] 		      avm_i_burstcount_o;
   input 			      avm_i_waitrequest_i;
   input 			      avm_i_readdatavalid_i;


   
   mor1kx_bus_if_wb32
     #(.BUS_IF_TYPE(AVALON))
   mor1kx
     (
      .clk			(clk),
      .rst			(reset),
      
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
