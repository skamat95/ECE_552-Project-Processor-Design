module Flags(flags_out, clk, rst, wen, flags_in);

// flags[2] = Z; flags[1] = V; flags[0] = N
output [2:0] flags_out;
input clk; 
input rst; 
input wen; 
input [2:0] flags_in;

dff Z(.q(flags_out[2]), .d(flags_in[2]), .wen(wen), .clk(clk), .rst(rst));
dff V(.q(flags_out[1]), .d(flags_in[1]), .wen(wen), .clk(clk), .rst(rst));
dff N(.q(flags_out[0]), .d(flags_in[0]), .wen(wen), .clk(clk), .rst(rst));

endmodule
