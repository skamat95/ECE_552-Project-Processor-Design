//////////////// PADDSB ///////////////////////////////////////////////////////////////////////////////////////////////////////////
module PADDSB (Sat_Sum, A, B);

input [15:0] A, B; 		// Input data values
output [15:0] Sat_Sum; 		// Sum output
wire [15:0] Sum;

wire [3:0] ov;

addsub_4bit_ripple adder1(.Sum(Sum[3:0]), .Ovfl(ov[0]), .A(A[3:0]), .B(B[3:0]), .sub(1'b0));
addsub_4bit_ripple adder2(.Sum(Sum[7:4]), .Ovfl(ov[1]), .A(A[7:4]), .B(B[7:4]), .sub(1'b0));
addsub_4bit_ripple adder3(.Sum(Sum[11:8]), .Ovfl(ov[2]), .A(A[11:8]), .B(B[11:8]), .sub(1'b0));
addsub_4bit_ripple adder4(.Sum(Sum[15:12]), .Ovfl(ov[3]), .A(A[15:12]), .B(B[15:12]), .sub(1'b0));

assign Sat_Sum[3:0] = ov[0] ? (Sum[3] ? 4'b0111 : 4'b1000) : Sum[3:0];
assign Sat_Sum[7:4] = ov[1] ? (Sum[7] ? 4'b0111 : 4'b1000) : Sum[7:4];
assign Sat_Sum[11:8] = ov[2] ? (Sum[11] ? 4'b0111 : 4'b1000) : Sum[11:8];
assign Sat_Sum[15:12] = ov[3] ? (Sum[15] ? 4'b0111 : 4'b1000) : Sum[15:12];

endmodule


/////// SINGLE BIT ADDER SLICE ////////////////////////////////////////////////////////////////////////////////////////////

module full_rippleadder_1bit(sum, cout, a, b, cin);
input  a, b; 		//Input values
input cin; 		// carry in
output sum; 		//sum output
output cout; 		//carryout

assign sum = a^b^cin;
assign cout = a&b | b&cin | a&cin;
endmodule

///////// 4 BIT ADDER SLICE ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module addsub_4bit_ripple (Sum, Ovfl, A, B, sub);

input [3:0] A, B; 	//Input values
input sub; 		// add-sub indicator
output [3:0] Sum; 	//sum output
output Ovfl; 		//To indicate overflow

wire [3:0]B_inv;
wire [3:0]carrybit;
wire both_neg, both_pos;


assign B_inv = sub ? ~B : B;
assign both_neg = A[3] & B_inv[3];
assign both_pos = ~A[3] & ~B_inv[3];

full_rippleadder_1bit FA1(.sum(Sum[0]), .cout(carrybit[0]), .a(A[0]), .b(B_inv[0]), .cin(sub));
full_rippleadder_1bit FA2(.sum(Sum[1]), .cout(carrybit[1]), .a(A[1]), .b(B_inv[1]), .cin(carrybit[0]));
full_rippleadder_1bit FA3(.sum(Sum[2]), .cout(carrybit[2]), .a(A[2]), .b(B_inv[2]), .cin(carrybit[1]));
full_rippleadder_1bit FA4(.sum(Sum[3]), .cout(carrybit[3]), .a(A[3]), .b(B_inv[3]), .cin(carrybit[2]));

assign  Ovfl = both_pos & Sum[3] | both_neg & ~Sum[3];

endmodule
