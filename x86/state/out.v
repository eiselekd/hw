`include "state.v"

module our (
  // system signals
  input wire clk,
  input wire rst,
  output     x86 v
);

x86  state_i;
x86  state_r;
reg 	  [3:0]   cnt;

assign v = state_r;

always @ (posedge clk, posedge rst)
  if (rst)
    $display("Reset");
  else
    begin
       cnt = cnt + 1;
       state_r <= state_i;
       $display("Assign");
    end

always @ (*)
  begin
     x86 state_v = state_r;
     state_v.r[0][3:0] = cnt;
     state_v.r[1][3:0] = cnt;
     state_v.r[2][3:0] = cnt;
     state_v.r[3][3:0] = cnt;
     state_i = state_v;
  end


endmodule
