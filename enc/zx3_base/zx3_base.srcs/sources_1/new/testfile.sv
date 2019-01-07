`timescale 1ns / 1ps

`define EXPOSZ 2

typedef struct packed {
    bit [3:0]   expo;
    bit         sign;
    bit [2:0]   mant;
} FP;

typedef struct packed {
    reg [3:0]  expo;
    reg        sign;
    reg [2:0]  mant;
} FP_reg;

module testfile (
  // system signals
  input wire clk,
  input wire rst,
  output wire [7:0] fp
);

FP  fp_w;
FP  fp_i;
FP_reg  fp_r;

assign fp = fp_r;

always @ (posedge clk, posedge rst)
  if (rst)
    fp_r <= {$size(fp_r){1'b0}};
  else
    begin
       fp_r <= fp_i;
    end

always @ (*)
  begin
     FP fp_v = fp_r;
     fp_v = '{ fp_v.expo+1, 1'b0, 3'b0 };
     fp_i = fp_v;
     //$display(fp_i);
  end

endmodule