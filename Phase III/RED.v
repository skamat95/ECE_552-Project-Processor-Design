module RED(A, B, OUT);
input [15:0] A, B;
output [15:0] OUT;

wire [3:0]cout;				// intermediate carry for lower and upper sums
wire [1:0]carry; 			// carry bit for final add
wire [11:0] lower_sum, upper_sum;	// for sum of lower and upper 8 bits	
wire [1:0]ovfl;

// adding the lower 8 bits and storing in lower_sum
adder_4bit lowadd(.a(A[3:0]), .b(B[3:0]), .cin(1'b0), .sum(lower_sum[3:0]), .cout(cout[0]), .ovfl(), .G(), .P());
adder_4bit lowadd2(.a(A[7:4]), .b(B[7:4]), .cin(cout[0]), .sum(lower_sum[7:4]), .cout(cout[1]), .ovfl(ovfl[0]), .G(), .P());

// partial sum sign extension, based on overflow and carryout
assign lower_sum[11:8] = (ovfl[0]) ? ((cout[1]) ? 4'b1111 : 4'b0000) : ({4{lower_sum[7]}});


//adding upper 8 bits and storing in upper_sum
adder_4bit upadd(.a(A[11:8]), .b(B[11:8]), .cin(1'b0), .sum(upper_sum[3:0]), .cout(cout[2]), .ovfl(), .G(), .P());
adder_4bit upadd2(.a(A[15:12]), .b(B[15:12]), .cin(cout[2]), .sum(upper_sum[7:4]), .cout(cout[3]), .ovfl(ovfl[1]), .G(), .P());

// partial sum sign extension, based on overflow and carryout
assign upper_sum[11:8] = ovfl[1] ? (cout[3] ? 4'b1111 : 4'b0000) : {4{upper_sum[7]}};

//final sum of lower and upper bits, there will be no overflow in this case as it is sign extension
adder_4bit uplowadd0(.a(lower_sum[3:0]), .b(upper_sum[3:0]), .cin(1'b0), .sum(OUT[3:0]), .cout(carry[0]), .ovfl(), .G(), .P());
adder_4bit uplowadd1(.a(lower_sum[7:4]), .b(upper_sum[7:4]), .cin(carry[0]), .sum(OUT[7:4]), .cout(carry[1]), .ovfl(), .G(), .P());
adder_4bit uplowadd2(.a(lower_sum[11:8]), .b(upper_sum[11:8]), .cin(carry[1]), .sum(OUT[11:8]), .cout(), .ovfl(), .G(), .P());

assign OUT[15:12] = {4{OUT[11]}};

endmodule

