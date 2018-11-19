//Main RegisterFile Module
module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);
input clk;
input rst;   
input [3:0] SrcReg1;
input [3:0] SrcReg2;
input [3:0] DstReg;
input WriteReg; 
input [15:0] DstData;
inout [15:0] SrcData1;
inout [15:0] SrcData2;
wire [15:0] read_en1, read_en2;
wire [15:0] write_en;
wire [15:0] SrcData_reg_1;
wire [15:0] SrcData_reg_2;

ReadDecoder_4_16 src1(.RegId(SrcReg1),  .Wordline(read_en1));
ReadDecoder_4_16 src2(.RegId(SrcReg2),  .Wordline(read_en2));
WriteDecoder_4_16 dstn(.RegId(DstReg),  .WriteReg(WriteReg), .Wordline(write_en));

Register Reg0(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[0]), .ReadEnable1(read_en1[0]), .ReadEnable2(read_en2[0]), .Bitline1(), .Bitline2());
assign SrcData1 = (read_en1[0]) ? 16'h0000 : SrcData_reg_1; 
assign SrcData2 = (read_en2[0]) ? 16'h0000 : SrcData_reg_2;
Register Reg1(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[1]), .ReadEnable1(read_en1[1]), .ReadEnable2(read_en2[1]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg2(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[2]), .ReadEnable1(read_en1[2]), .ReadEnable2(read_en2[2]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg3(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[3]), .ReadEnable1(read_en1[3]), .ReadEnable2(read_en2[3]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg4(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[4]), .ReadEnable1(read_en1[4]), .ReadEnable2(read_en2[4]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg5(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[5]), .ReadEnable1(read_en1[5]), .ReadEnable2(read_en2[5]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg6(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[6]), .ReadEnable1(read_en1[6]), .ReadEnable2(read_en2[6]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg7(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[7]), .ReadEnable1(read_en1[7]), .ReadEnable2(read_en2[7]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg8(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[8]), .ReadEnable1(read_en1[8]), .ReadEnable2(read_en2[8]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg9(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[9]), .ReadEnable1(read_en1[9]), .ReadEnable2(read_en2[9]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg10(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[10]), .ReadEnable1(read_en1[10]), .ReadEnable2(read_en2[10]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg11(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[11]), .ReadEnable1(read_en1[11]), .ReadEnable2(read_en2[11]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg12(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[12]), .ReadEnable1(read_en1[12]), .ReadEnable2(read_en2[12]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg13(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[13]), .ReadEnable1(read_en1[13]), .ReadEnable2(read_en2[13]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg14(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[14]), .ReadEnable1(read_en1[14]), .ReadEnable2(read_en2[14]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
Register Reg15(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_en[15]), .ReadEnable1(read_en1[15]), .ReadEnable2(read_en2[15]), .Bitline1(SrcData_reg_1), .Bitline2(SrcData_reg_2));
endmodule


//Read-Decoder Module
module ReadDecoder_4_16(RegId,  Wordline);
input [3:0] RegId;
output [15:0] Wordline;

assign Wordline = (RegId == 4'h0) ? 16'h0001 : 
		  (RegId == 4'h1) ? 16'h0002 :	
		  (RegId == 4'h2) ? 16'h0004 :	
		  (RegId == 4'h3) ? 16'h0008 :	
		  (RegId == 4'h4) ? 16'h0010 :	
		  (RegId == 4'h5) ? 16'h0020 :	
		  (RegId == 4'h6) ? 16'h0040 :	
		  (RegId == 4'h7) ? 16'h0080 :	
		  (RegId == 4'h8) ? 16'h0100 :	
		  (RegId == 4'h9) ? 16'h0200 :	
		  (RegId == 4'ha) ? 16'h0400 :	
		  (RegId == 4'hb) ? 16'h0800 :	
		  (RegId == 4'hc) ? 16'h1000 :	
		  (RegId == 4'hd) ? 16'h2000 :	
		  (RegId == 4'he) ? 16'h4000 :	16'h8000 ;
endmodule

//Write-Decoder Module
module WriteDecoder_4_16(RegId, WriteReg, Wordline);
input [3:0] RegId;
input WriteReg;
output [15:0] Wordline;

assign Wordline = (!WriteReg) ? 16'h0000 : ((RegId == 4'h0) ? 16'h0000 : 
		  (RegId == 4'h1) ? 16'h0002 :	
		  (RegId == 4'h2) ? 16'h0004 :	
		  (RegId == 4'h3) ? 16'h0008 :	
		  (RegId == 4'h4) ? 16'h0010 :	
		  (RegId == 4'h5) ? 16'h0020 :	
		  (RegId == 4'h6) ? 16'h0040 :	
		  (RegId == 4'h7) ? 16'h0080 :	
		  (RegId == 4'h8) ? 16'h0100 :	
		  (RegId == 4'h9) ? 16'h0200 :	
		  (RegId == 4'ha) ? 16'h0400 :	
		  (RegId == 4'hb) ? 16'h0800 :	
		  (RegId == 4'hc) ? 16'h1000 :	
		  (RegId == 4'hd) ? 16'h2000 :	
		  (RegId == 4'he) ? 16'h4000 : 16'h8000);
endmodule

//Bit-cell module
module BitCell(clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2, Bitline1, Bitline2);
input clk;
input rst;
input D;
input WriteEnable;
input ReadEnable1;
input ReadEnable2;
inout Bitline1;
inout Bitline2;
wire Q;

dff FF(.q(Q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));
assign Bitline1 = (ReadEnable1 ? Q : 1'bz);
assign Bitline2 = (ReadEnable2 ? Q : 1'bz);
endmodule


//Register module
module Register(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

input clk;
input rst;
input [15:0] D;
input WriteReg;
input ReadEnable1;
input ReadEnable2;
inout [15:0] Bitline1;
inout [15:0] Bitline2;

BitCell bcell0(.clk(clk), .rst(rst), .D(D[0]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[0]), .Bitline2(Bitline2[0]));
BitCell bcell1(.clk(clk), .rst(rst), .D(D[1]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[1]), .Bitline2(Bitline2[1]));
BitCell bcell2(.clk(clk), .rst(rst), .D(D[2]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[2]), .Bitline2(Bitline2[2]));
BitCell bcell3(.clk(clk), .rst(rst), .D(D[3]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[3]), .Bitline2(Bitline2[3]));
BitCell bcell4(.clk(clk), .rst(rst), .D(D[4]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[4]), .Bitline2(Bitline2[4]));
BitCell bcell5(.clk(clk), .rst(rst), .D(D[5]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[5]), .Bitline2(Bitline2[5]));
BitCell bcell6(.clk(clk), .rst(rst), .D(D[6]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[6]), .Bitline2(Bitline2[6]));
BitCell bcell7(.clk(clk), .rst(rst), .D(D[7]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[7]), .Bitline2(Bitline2[7]));
BitCell bcell8(.clk(clk), .rst(rst), .D(D[8]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[8]), .Bitline2(Bitline2[8]));
BitCell bcell9(.clk(clk), .rst(rst), .D(D[9]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[9]), .Bitline2(Bitline2[9]));
BitCell bcell10(.clk(clk), .rst(rst), .D(D[10]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[10]), .Bitline2(Bitline2[10]));
BitCell bcell11(.clk(clk), .rst(rst), .D(D[11]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[11]), .Bitline2(Bitline2[11]));
BitCell bcell12(.clk(clk), .rst(rst), .D(D[12]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[12]), .Bitline2(Bitline2[12]));
BitCell bcell13(.clk(clk), .rst(rst), .D(D[13]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[13]), .Bitline2(Bitline2[13]));
BitCell bcell14(.clk(clk), .rst(rst), .D(D[14]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[14]), .Bitline2(Bitline2[14]));
BitCell bcell15(.clk(clk), .rst(rst), .D(D[15]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[15]), .Bitline2(Bitline2[15]));
endmodule
