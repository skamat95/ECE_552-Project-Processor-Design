module xor_16bit(A,B,OUT);
input [15:0]A,B;
output [15:0]OUT;

assign OUT = A^B;

endmodule
