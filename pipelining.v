module dflipflop_4bit (q, d, wen, clk, rst);

output [3:0] q; 
input [3:0] d; 
input wen; 
input clk; 
input rst;

dff dff0(.q(q[0]), .d(d[0]), .wen(wen), .clk(clk), .rst(rst));
dff dff1(.q(q[1]), .d(d[1]), .wen(wen), .clk(clk), .rst(rst));
dff dff2(.q(q[2]), .d(d[2]), .wen(wen), .clk(clk), .rst(rst));
dff dff3(.q(q[3]), .d(d[3]), .wen(wen), .clk(clk), .rst(rst));
endmodule

module dflipflop_3bit (q, d, wen, clk, rst);

output [2:0] q; 
input [2:0] d; 
input wen; 
input clk; 
input rst;

dff dff0(.q(q[0]), .d(d[0]), .wen(wen), .clk(clk), .rst(rst));
dff dff1(.q(q[1]), .d(d[1]), .wen(wen), .clk(clk), .rst(rst));
dff dff2(.q(q[2]), .d(d[2]), .wen(wen), .clk(clk), .rst(rst));
endmodule

module IF_ID(clk, rst_n, Inst, pc, IF_Flush, stall, hlt, IF_ID_Inst, IF_ID_next_pc, IF_ID_hlt);

input clk;
input rst_n;
input[15:0] Inst;
input[15:0] pc;
input IF_Flush;
input stall;
input hlt;
output[15:0] IF_ID_Inst;
output[15:0] IF_ID_next_pc; //already incremented by 2
output IF_ID_hlt;

wire [15:0] Inst_imm; //Intermediate values
//wire [15:0] pc_imm;
wire hlt_imm;

dflipflop_16bit inst (.q(IF_ID_Inst), .d(Inst_imm), .wen(~stall), .clk(clk), .rst(~rst_n));
dflipflop_16bit PC (.q(IF_ID_next_pc), .d(pc), .wen(~stall), .clk(clk), .rst(~rst_n));
dff halt(.q(IF_ID_hlt), .d(hlt_imm), .wen(~stall), .clk(clk), .rst(~rst_n));
assign Inst_imm = IF_Flush ? (16'h4000) :(Inst);
//assign pc_imm =  IF_Flush ? (16'h0000) : (pc);
assign hlt_imm = IF_Flush ? (1'b0) : hlt;

endmodule


module ID_EX(clk, rst_n, opcode, SrcData1, SrcData2, imm_4bit, sign_extend, SrcReg1, SrcReg2, DstReg, ID_Flush, RegWrite, MemRead, MemWrite, MemtoReg, IF_ID_next_pc, flag_br_checker, IF_ID_hlt,
ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_MemtoReg, ID_EX_RegVal1, ID_EX_RegVal2, ID_EX_sign_extend, ID_EX_RsAddr, ID_EX_RtAddr, ID_EX_RdAddr, ID_EX_imm_4bit, ID_EX_opcode, ID_EX_next_pc, ID_EX_flag_br_checker, ID_EX_hlt);

input clk, rst_n, ID_Flush;
input [3:0] opcode;
input [3:0] imm_4bit;
input [15:0] SrcData1, SrcData2, sign_extend;
input [3:0] SrcReg1, SrcReg2, DstReg;//check
input RegWrite, MemRead, MemWrite, MemtoReg;
input [15:0] IF_ID_next_pc;
input flag_br_checker;
input IF_ID_hlt;
output ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_MemtoReg;
output [15:0] ID_EX_RegVal1, ID_EX_RegVal2, ID_EX_sign_extend;
output [3:0] ID_EX_RsAddr, ID_EX_RtAddr, ID_EX_RdAddr, ID_EX_imm_4bit;
output [3:0] ID_EX_opcode;
output [15:0] ID_EX_next_pc;
output ID_EX_flag_br_checker;
output ID_EX_hlt;

wire ID_EX_RegWrite_imm, ID_EX_MemRead_imm, ID_EX_MemWrite_imm, ID_EX_MemtoReg_imm;

assign ID_EX_RegWrite_imm = ID_Flush ? (1'b0) : (RegWrite);
assign ID_EX_MemRead_imm = ID_Flush ? (1'b0) : (MemRead);
assign ID_EX_MemWrite_imm = ID_Flush ? (1'b0) : (MemWrite);
assign ID_EX_MemtoReg_imm = ID_Flush ? (1'b0) : (MemtoReg);
dff regwr(.q(ID_EX_RegWrite), .d(ID_EX_RegWrite_imm), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff memrd(.q(ID_EX_MemRead), .d(ID_EX_MemRead_imm), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff memwr(.q(ID_EX_MemWrite), .d(ID_EX_MemWrite_imm), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff memreg(.q(ID_EX_MemtoReg), .d(ID_EX_MemtoReg_imm), .wen(1'b1), .clk(clk), .rst(~rst_n));

dflipflop_16bit Data0 (.q(ID_EX_RegVal1), .d(SrcData1), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_16bit Data1 (.q(ID_EX_RegVal2), .d(SrcData2), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_16bit pc (.q(ID_EX_next_pc), .d(IF_ID_next_pc), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_4bit imm (.q(ID_EX_imm_4bit), .d(imm_4bit), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_16bit sgn (.q(ID_EX_sign_extend), .d(sign_extend), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_4bit Data2 (.q(ID_EX_RsAddr), .d(SrcReg1), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_4bit Data3 (.q(ID_EX_RtAddr), .d(SrcReg2), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_4bit Data4 (.q(ID_EX_RdAddr), .d(DstReg), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_4bit Data5 (.q(ID_EX_opcode), .d(opcode), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_4bit op (.q(ID_EX_opcode), .d(opcode), .wen(1'b1), .clk(clk), .rst(~rst_n));

dff flag(.q(ID_EX_flag_br_checker), .d(flag_br_checker), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff halt_0(.q(ID_EX_hlt), .d(IF_ID_hlt), .wen(1'b1), .clk(clk), .rst(~rst_n));

endmodule

module EX_MEM(clk, rst_n, ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_MemtoReg, ALUOut, ID_EX_RdAddr, MemData, ID_EX_flag_br_checker, flag_wen, flags_in, ID_EX_hlt,
EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_MemtoReg, EX_MEM_MemData, EX_MEM_RdAddr, EX_MEM_ALUOut, EX_MEM_flag_br_checker, EX_MEM_flags, EX_MEM_hlt);

input clk;
input rst_n;
input ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_MemtoReg;
input [15:0] ALUOut;
input [3:0] ID_EX_RdAddr;
input [15:0] MemData;
input ID_EX_flag_br_checker;
input flag_wen;
input [2:0] flags_in;
input ID_EX_hlt;
output EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_MemtoReg;
output [15:0] EX_MEM_MemData;
output [3:0] EX_MEM_RdAddr;
output [15:0] EX_MEM_ALUOut;
output EX_MEM_flag_br_checker;
output [2:0] EX_MEM_flags;
output EX_MEM_hlt;

dff RegWrt(.q(EX_MEM_RegWrite), .d(ID_EX_RegWrite), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff MemRead(.q(EX_MEM_MemRead), .d(ID_EX_MemRead), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff MemWrt(.q(EX_MEM_MemWrite), .d(ID_EX_MemWrite), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff MemtoRg(.q(EX_MEM_MemtoReg), .d(ID_EX_MemtoReg), .wen(1'b1), .clk(clk), .rst(~rst_n));

dflipflop_16bit mem (.q(EX_MEM_MemData), .d(MemData), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_16bit aluout (.q(EX_MEM_ALUOut), .d(ALUOut), .wen(1'b1), .clk(clk), .rst(~rst_n));

dflipflop_4bit Rd (.q(EX_MEM_RdAddr), .d(ID_EX_RdAddr), .wen(1'b1), .clk(clk), .rst(~rst_n));

dff flag_1(.q(EX_MEM_flag_br_checker), .d(ID_EX_flag_br_checker), .wen(1'b1), .clk(clk), .rst(~rst_n));

dflipflop_3bit flag_reg(.q(EX_MEM_flags), .d(flags_in), .wen(flag_wen), .clk(clk), .rst(~rst_n));
dff halt_1(.q(EX_MEM_hlt), .d(ID_EX_hlt), .wen(1'b1), .clk(clk), .rst(~rst_n));

endmodule

module MEM_WB(clk, rst_n, EX_MEM_RegWrite, EX_MEM_MemtoReg, EX_MEM_ALUOut, Dmem_out, EX_MEM_RdAddr, EX_MEM_flags, EX_MEM_hlt, EX_MEM_flag_br_checker,
MEM_WB_RegWrite, MEM_WB_MemtoReg, MEM_WB_ALUOut, MEM_WB_DmemOut, MEM_WB_RdAddr, MEM_WB_flags, MEM_WB_hlt, MEM_WB_flag_br_checker);

input clk;
input rst_n;
input EX_MEM_RegWrite, EX_MEM_MemtoReg;
input [15:0] EX_MEM_ALUOut, Dmem_out;
input [3:0] EX_MEM_RdAddr;
input EX_MEM_flag_br_checker;
input [2:0] EX_MEM_flags;
input EX_MEM_hlt;
output MEM_WB_RegWrite, MEM_WB_MemtoReg;
output [15:0] MEM_WB_ALUOut, MEM_WB_DmemOut;
output [3:0] MEM_WB_RdAddr;
output MEM_WB_flag_br_checker;
output [2:0] MEM_WB_flags;
output MEM_WB_hlt;

dff RegWrt(.q(MEM_WB_RegWrite), .d(EX_MEM_RegWrite), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff MemtoReg(.q(MEM_WB_MemtoReg), .d(EX_MEM_MemtoReg), .wen(1'b1), .clk(clk), .rst(~rst_n));

dflipflop_16bit dmemout (.q(MEM_WB_DmemOut), .d(Dmem_out), .wen(1'b1), .clk(clk), .rst(~rst_n));
dflipflop_16bit aluout (.q(MEM_WB_ALUOut), .d(EX_MEM_ALUOut), .wen(1'b1), .clk(clk), .rst(~rst_n));

dflipflop_4bit Rd (.q(MEM_WB_RdAddr), .d(EX_MEM_RdAddr), .wen(1'b1), .clk(clk), .rst(~rst_n));


dflipflop_3bit flag_reg_2(.q(MEM_WB_flags), .d(EX_MEM_flags), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff halt_2(.q(MEM_WB_hlt), .d(EX_MEM_hlt), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff br_flag(.q(MEM_WB_flag_br_checker), .d(EX_MEM_flag_br_checker), .wen(1'b1), .clk(clk), .rst(~rst_n));

endmodule
