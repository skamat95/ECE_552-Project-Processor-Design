//Tag Array of 128  blocks 2^7/2^2 = 2^5 sets
//32 sets, Each set with 4 blocks
//Each block will have 1 byte
//BlockEnable is one-hot
//WriteEnable is one on writes and zero on reads

module MetaDataArray(input clk, input rst, input [39:0] DataIn, input Write, input Lru_en, input [31:0] BlockEnable, output [39:0] DataOut);
  MBlock Mblk0[31:0]( .clk(clk), .rst(rst), .Din(DataIn[9:0]), .WriteEnable(Write), .Lru_en(Lru_en), .Enable(BlockEnable[31:0]), .Dout(DataOut[9:0]));
  MBlock Mblk1[31:0]( .clk(clk), .rst(rst), .Din(DataIn[19:10]), .WriteEnable(Write), .Lru_en(Lru_en), .Enable(BlockEnable[31:0]), .Dout(DataOut[19:10]));
  MBlock Mblk2[31:0]( .clk(clk), .rst(rst), .Din(DataIn[29:20]), .WriteEnable(Write), .Lru_en(Lru_en), .Enable(BlockEnable[31:0]), .Dout(DataOut[29:20]));
  MBlock Mblk3[31:0]( .clk(clk), .rst(rst), .Din(DataIn[39:30]), .WriteEnable(Write), .Lru_en(Lru_en), .Enable(BlockEnable[31:0]), .Dout(DataOut[39:30]));
endmodule

module MBlock( input clk, input rst, input [9:0] Din, input WriteEnable, input Lru_en, input Enable, output [9:0] Dout);
	MCell mc[7:0]( .clk(clk), .rst(rst), .Din(Din[7:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[7:0]));
        MCell lru[1:0]( .clk(clk), .rst(rst), .Din(Din[9:8]), .WriteEnable(WriteEnable | Lru_en), .Enable(Enable), .Dout(Dout[9:8]));
endmodule

module MCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~(WriteEnable)) ? q:'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & (WriteEnable)), .clk(clk), .rst(rst));
endmodule
