module Shifter_16bit(Shift_In, Mode_In, Shift_Val, Shift_Out);

input[15:0] Shift_In;
input [1:0] Mode_In; 
input [3:0] Shift_Val;
output[15:0] Shift_Out;
wire [15:0] Shift_Out0, Shift_Out1, Shift_Out2;

// mode 00:SLL
// mode 01:SRA
// mode 10:ROR

Shifter_1_bit_3_1 bit0(.Shift_In(Shift_In), .Mode_In(Mode_In), .Enable(Shift_Val[0]), .Shift_Out(Shift_Out0));
Shifter_2_bit_3_1 bit1(.Shift_In(Shift_Out0), .Mode_In(Mode_In), .Enable(Shift_Val[1]), .Shift_Out(Shift_Out1));
Shifter_4_bit_3_1 bit2(.Shift_In(Shift_Out1), .Mode_In(Mode_In), .Enable(Shift_Val[2]), .Shift_Out(Shift_Out2));
Shifter_8_bit_3_1 bit3(.Shift_In(Shift_Out2), .Mode_In(Mode_In), .Enable(Shift_Val[3]), .Shift_Out(Shift_Out));

endmodule

//Shift by 8 module
module Shifter_8_bit_3_1(Shift_In, Mode_In, Enable, Shift_Out);

input[15:0] Shift_In;
input [1:0] Mode_In; 
input Enable;
output[15:0] Shift_Out;
reg [15:0] Shift_Out_pre;
//wire [1:0] Mode;

// mode 00:SLL
// mode 01:SRA
// mode 10:ROR

//assign Mode = (Mode_In == 2'b11) ? 2'b10 : Mode_In;

always @* begin
       case(Mode_In)
        2'b00: Shift_Out_pre = {{Shift_In[7:0]}, 8'b00000000};
        2'b01: Shift_Out_pre = {{8{Shift_In[15]}},Shift_In[15:8]};
        2'b10: Shift_Out_pre = {Shift_In[7:0],Shift_In[15:8]};
	default	: Shift_Out_pre = Shift_In;
	endcase
end 

assign Shift_Out = Enable ? Shift_Out_pre : Shift_In;

endmodule

//Shift by 4 module
module Shifter_4_bit_3_1(Shift_In, Mode_In, Enable, Shift_Out);

input[15:0] Shift_In;
input [1:0] Mode_In; 
input Enable;
output[15:0] Shift_Out;
reg [15:0] Shift_Out_pre;
//wire [1:0] Mode;

// mode 00:SLL
// mode 01:SRA
// mode 10:ROR

//assign Mode = (Mode_In == 2'b11) ? 2'b10 : Mode_In;
always @* begin
       case(Mode_In)
        2'b00: Shift_Out_pre = {{Shift_In[11:0]}, 4'b0000};
        2'b01: Shift_Out_pre = {{4{Shift_In[15]}},Shift_In[15:4]};
        2'b10: Shift_Out_pre = {Shift_In[3:0],Shift_In[15:4]};
	default	: Shift_Out_pre = Shift_In;
	endcase
end 

assign Shift_Out = Enable ? Shift_Out_pre : Shift_In;

endmodule

//Shift by 2 module
module Shifter_2_bit_3_1(Shift_In, Mode_In, Enable, Shift_Out);

input[15:0] Shift_In;
input [1:0] Mode_In; 
input Enable;
output[15:0] Shift_Out;
reg [15:0] Shift_Out_pre;
//wire [1:0] Mode;

// mode 00:SLL
// mode 01:SRA
// mode 10:ROR

//assign Mode = (Mode_In == 2'b11) ? 2'b10 : Mode_In;

always @* begin
       case(Mode_In)
        2'b00: Shift_Out_pre = {{Shift_In[13:0]}, 2'b00};
        2'b01: Shift_Out_pre = {{2{Shift_In[15]}},Shift_In[15:2]};
        2'b10: Shift_Out_pre = {Shift_In[1:0],Shift_In[15:2]};
	default	: Shift_Out_pre = Shift_In;
	endcase
end 

assign Shift_Out = Enable ? Shift_Out_pre : Shift_In;

endmodule

//Shift by 1 module
module Shifter_1_bit_3_1(Shift_In, Mode_In, Enable, Shift_Out);

input[15:0] Shift_In;
input [1:0] Mode_In; 
input Enable;
output[15:0] Shift_Out;
reg [15:0] Shift_Out_pre;
//wire [1:0] Mode;

// mode 00:SLL
// mode 01:SRA
// mode 10:ROR

//assign Mode = (Mode_In == 2'b11) ? 2'b10 : Mode_In;

always @* begin
       case(Mode_In)
        2'b00: Shift_Out_pre = {{Shift_In[14:0]}, 1'b0};
        2'b01: Shift_Out_pre = {Shift_In[15],Shift_In[15:1]};
        2'b10: Shift_Out_pre = {Shift_In[0],Shift_In[15:1]};
	default	: Shift_Out_pre = Shift_In;
	endcase
end 

assign Shift_Out = Enable ? Shift_Out_pre : Shift_In;

endmodule
