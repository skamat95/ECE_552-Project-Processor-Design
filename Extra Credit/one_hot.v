//One hot 64 bit
//Takes in address, uses 6 Set Bits and gives out one-hot of 64 bits.

module Shifter_64bit(address_in, Shift_Out); //Choosing block-enable in metadata and data array
input [15:0] address_in;
wire [5:0] set = address_in[9:4]; //Set index bits

output [63:0] Shift_Out; //Final one hot output

wire [3:0] Shift_Val = set[3:0];
wire [15:0] Shift_Out_imm;

Shifter_16bit S0(.Shift_In(16'h0001), .Mode_In(2'b00), .Shift_Val(Shift_Val), .Shift_Out(Shift_Out_imm)); //SLL mode is 00

assign Shift_Out[15:0] = ((set[5] == 0) && (set[4] == 0)) ? Shift_Out_imm : 16'h0000;
assign Shift_Out[31:16] = ((set[5] == 0) && (set[4] == 1)) ? Shift_Out_imm : 16'h0000;
assign Shift_Out[47:32] = ((set[5] == 1) && (set[4] == 0)) ? Shift_Out_imm : 16'h0000;
assign Shift_Out[63:48] = ((set[5] == 1) && (set[4] == 1)) ? Shift_Out_imm : 16'h0000;

endmodule

module Shifter_32bit(address_in, Shift_Out); //Choosing block-enable in metadata and data array
input [15:0] address_in;
wire [4:0] set = address_in[8:4]; //Set index bits

output [31:0] Shift_Out; //Final one hot output

wire [3:0] Shift_Val = set[3:0];
wire [15:0] Shift_Out_imm;

Shifter_16bit S0(.Shift_In(16'h0001), .Mode_In(2'b00), .Shift_Val(Shift_Val), .Shift_Out(Shift_Out_imm)); //SLL mode is 00

assign Shift_Out[15:0] = (set[4] == 0) ? Shift_Out_imm : 16'h0000;
assign Shift_Out[31:16] = (set[4] == 1) ? Shift_Out_imm : 16'h0000;


endmodule

