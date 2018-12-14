//////////////// CALL BEFORE ANY EDIT ////////////////////////////////////////////////////////////////////////////

module ALU(Inst, ALUIn1, ALUIn2, Shift_Val, ALUOut, Z, V, N);

input [3:0] Inst;			//OPCODE
input [15:0] ALUIn1, ALUIn2;		// need to select the input among register and immediate for shift function
input [3:0] Shift_Val; //Unsigned 4-bit value for shifts - sll, sla, ror
output reg [15:0] ALUOut; //ALU output
output reg Z;			// zero flag
output reg V, N;		// flags overflow and negative
wire [15:0] sum_out, xor_out, PADDSB_out, RED_out, shifter_out;		
wire overflow;			// overflow			
wire [1:0]shifter_mode;		// rotate , sll or sra	
wire cin; 			// carry input for adder/sub 

//assign Z = (|ALUOut == 0)? 1:0;
assign cin = (!Inst[3]) ? Inst[0] : 0;
assign shifter_mode = (Inst[2]) ? Inst[1:0] : 2'b11;

cla_16bit addsub(.A(ALUIn1), .B(ALUIn2), .cin(cin), .Sat_Sum(sum_out), .Ovfl(overflow));
xor_16bit xorout(.A(ALUIn1),.B(ALUIn2),.OUT(xor_out));
RED reduction(.A(ALUIn1),.B(ALUIn2),.OUT(RED_out));
PADDSB PSA(.Sat_Sum(PADDSB_out), .A(ALUIn1), .B(ALUIn2));
Shifter_16bit shiftrotate(.Shift_In(ALUIn1), .Mode_In(shifter_mode), .Shift_Val(Shift_Val), .Shift_Out(shifter_out));

always @* begin 
casex (Inst[3:0])

	4'b000x  : 	begin 						// ADD and SUB				
			ALUOut = sum_out;
			N = sum_out[15];
			V = overflow;
			Z = (|ALUOut == 0)? 1:0;
		  	end
/*	4'b0001 : begin 						// SUB				
			ALUOut = sum_out;
			N = sum_out[15];
			V = overflow;
		   end */
	4'b0010 : 	begin
			ALUOut = xor_out;				// XOR 
		  	Z = (|ALUOut == 0)? 1:0;
			end 
	4'b0011 : 	begin
			ALUOut = RED_out;				// Reduction opeartion
			Z = (|ALUOut == 0)? 1:0;
			end

	4'b0111 : 	begin
			ALUOut = PADDSB_out;				// PADDSB
			Z = (|ALUOut == 0)? 1:0;
			end

	4'b01xx : 	begin
			ALUOut = shifter_out;				// shift & rotate
			Z = (|ALUOut == 0)? 1:0;
			end
/*	4'b0101 : 	ALUOut = shifter_out;				// sra
		   
	4'b0110 : 	ALUOut = shifter_out;				// rotate
	*/		
//	4'b1000 : 	ALUOut = sum_out;				// load 
	4'b1xxx : 	ALUOut = sum_out;	  			// load and store
//	4'b1001 : 	ALUOut = sum_out;				// store		
		   
	default : ALUOut = 16'h0001;
endcase 

end

endmodule
