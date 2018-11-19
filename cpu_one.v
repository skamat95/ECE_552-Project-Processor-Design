module cpu(clk, rst_n, hlt, pc);
//IO ports
input clk;
input rst_n;
output hlt;
output [15:0] pc;

//all initializations
wire Inst_enable;
wire [15:0] Inst;
wire Inst_wr; //write for imem - tied off to 1'b0 - unused
wire [15:0] Inst_data_in; //Tied off to 16'b0 - unused
wire [3:0] opcode;
wire [3:0] DstReg;
wire [3:0] SrcReg1;
wire [3:0] SrcReg2;
wire [3:0] imm_4bit;
wire [7:0] imm_8bit;
wire [8:0] imm_9bit;
wire [2:0] br_condition; //branch condition encoding
wire [15:0] SrcData1;
wire [15:0] SrcData2;
wire [15:0] DstData;
wire [15:0] SrcData2_or_Imm;
wire [15:0] SrcData1_pre;
wire br_true; //If this is true, B/BR will be taken
wire [2:0] flags_in;
//wire [2:0] flags_out;
wire MemtoReg;
wire MemRead;
wire MemWrite;
wire RegWrite;
wire pc_overflow; //unused currently
wire br_overflow; //unused currently
wire [15:0]branch_pc;
wire [15:0]next_pc;
wire pc_wen;
wire [15:0]br_offset;
wire [15:0]pc_in;
wire [15:0] Dmem_out;
//wire [15:0] Dmem_in;
wire [15:0] ALUOut;
wire Z, N, V, flag_wen;


//Phase_2 wires
wire stall;
wire [15:0] IF_ID_Inst; 
//wire IF_ID_RegisterRs;
//wire IF_ID_RegisterRt; 
//wire ID_EX_RegisterRt; 
//wire ID_EX_RegisterRd;
//wire EX_MEM_RegisterRd; 
wire ID_EX_RegWrite;
wire EX_MEM_RegWrite; 
wire IF_Flush; 
wire ID_Flush;
wire [15:0] IF_ID_next_pc;
//wire ID_EX_RegDst; //Need Logic implementation in pipelining latch
wire ID_EX_MemRead;
wire ID_EX_MemtoReg;
wire ID_EX_MemWrite;
wire MEM_WB_MemtoReg;
wire MEM_WB_RegWrite;
wire [15:0] MEM_WB_ALUOut;
wire [15:0] MEM_WB_DmemOut;
wire [3:0] MEM_WB_RdAddr;
wire [3:0] EX_MEM_RdAddr;
wire [3:0] ID_EX_RdAddr;
wire [3:0] ID_EX_RtAddr;
wire [3:0] ID_EX_RsAddr;
//wire [3:0] EX_MEM_RegDst;
wire [15:0] EX_MEM_ALUOut;
wire [15:0] EX_MEM_MemData;
wire [1:0] forward_in1, forward_in2;
wire forward_mem_mux;
wire [15:0]EX_MEM_ALUIn;
wire [15:0] ID_EX_sign_extend;
wire [3:0] ID_EX_opcode;
wire [3:0] ID_EX_imm_4bit;
wire [15:0] sign_extend;
wire [15:0] ID_EX_SrcData2;
wire flag_br_checker;
wire [15:0]ID_EX_next_pc;
wire ID_EX_flag_br_checker, EX_MEM_flag_br_checker , MEM_WB_flag_br_checker;
wire ID_EX_hlt, EX_MEM_hlt, MEM_WB_hlt;
wire [2:0]EX_MEM_flags, MEM_WB_flags;
wire [15:0]ID_EX_SrcData1;
wire hlt_pre;
wire [15:0]ALUIn1, ALUIn2;
wire [15:0]data_in;
wire [15:0]LLB_LHB;
wire [15:0] SrcData1_raw;
wire [15:0] SrcData2_raw;
wire IF_ID_hlt;
//wire IF_ID_Inst_checker;

//Opcode assignment
assign opcode = IF_ID_Inst[15:12];

//ALUSrc
//assign ALUSrc = opcode[3];

//checking reset
assign Inst_enable = (~rst_n) ? 1'b0 : 1'b1;

//hlt instruction
assign hlt_pre = (Inst[15:12] == 4'b1111);
assign hlt = MEM_WB_hlt;

//PC register
assign pc_wen = (~rst_n || (hlt_pre & !IF_Flush) || stall) ? 1'b0 : 1'b1;
dflipflop_16bit program_counter(.q(pc), .d(pc_in), .wen(pc_wen), .clk(clk), .rst(~rst_n)); // 16 bit register to hold current pc value

//Imem
assign Inst_wr = 1'b0;
assign Inst_data_in = 16'b0;
memory1c IMEM(.data_out(Inst), .data_in(Inst_data_in), .addr(pc), .enable(Inst_enable), .wr(Inst_wr), .clk(clk), .rst(~rst_n));


//Assigns for RegFile Inputs
assign SrcReg1 = IF_ID_Inst[7:4]; //Always source register SrcReg1 -- ALU Src1
assign SrcReg2 = ((opcode == 4'b1000) | (opcode == 4'b1001) | opcode == 4'b1011 | opcode == 4'b1010) ? IF_ID_Inst[11:8] : IF_ID_Inst[3:0]; //Inst[11:8] is source register (from which value is to be stored in memory) for sw instruction, and source for LLB, LHB instructions
assign DstReg = IF_ID_Inst[11:8]; //Always destination register
//assign IF_ID_Inst_checker = IF_ID_Inst[0] | IF_ID_Inst[0] | IF_ID_Inst[0] | IF_ID_Inst[0] | IF_ID_Inst[0] | IF_ID_Inst[0];  
assign RegWrite = (((opcode[3] == 1'b0) || (opcode == 4'b1000) || (opcode == 4'b1010) || (opcode == 4'b1011) || (opcode == 4'b1110)) && IF_ID_next_pc != 16'b0)  ? 1'b1 : 1'b0;

//Immediate fields
assign imm_4bit = IF_ID_Inst[3:0]; //Always immediate 4-bit field for LW, SW
assign imm_8bit = IF_ID_Inst[7:0]; //Always immediate 8-bit field for LLB, LHB
assign imm_9bit = IF_ID_Inst[8:0]; //Always immediate 9-bit field for B
assign br_condition = IF_ID_Inst[11:9]; //Always immediate 3-bit branch condition for flag checking

//Regfile
RegisterFile Regfile(.clk(clk), .rst(~rst_n), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), .DstReg(MEM_WB_RdAddr), .WriteReg(MEM_WB_RegWrite), .DstData(DstData), .SrcData1(SrcData1_raw), .SrcData2(SrcData2_raw));
assign SrcData1_pre = ((SrcReg1 == MEM_WB_RdAddr) && (MEM_WB_RegWrite) && (MEM_WB_RdAddr != 4'b0)) ? DstData : SrcData1_raw; 
assign SrcData2 = ((SrcReg2 == MEM_WB_RdAddr) && (MEM_WB_RegWrite) && (MEM_WB_RdAddr != 4'b0)) ? DstData : SrcData2_raw;  

//Choose SrcData2 or Imm (only for LW/SW) as per opcode
assign SrcData2_or_Imm = (ID_EX_opcode[3] & ID_EX_opcode != 4'b1111) ?  ID_EX_sign_extend : ID_EX_SrcData2; //ALU Src2

//Enforcing LSB of address is 1'b0 for LW/SW
assign SrcData1 = (opcode[3]) ? (SrcData1_pre & 16'hFFFE) : SrcData1_pre; 

//ALUOp = 1 for Add, sub, xor, red, sll, sra, ror, paddsb, lw, sw. 
//assign ALUOp = (~opcode[3] | opcode == 4'b1001 | opcode == 4'b1000) ?  1'b1 : 1'b0;

//ALU - for ADD, SUB, RED, ROR, PADDSB, SLL, SRA, XOR, LW, SW.
assign ALUIn1 = (forward_in1 == 2'b00 || forward_in1 == 2'b11) ? ID_EX_SrcData1 : ((forward_in1 == 2'b10) ? EX_MEM_ALUOut : DstData);
assign ALUIn2 = ID_EX_opcode[3:1] == 3'b100 ? SrcData2_or_Imm : (forward_in2 == 2'b00 || forward_in2 == 2'b11) ? SrcData2_or_Imm : (forward_in2 == 2'b10) ? EX_MEM_ALUOut : DstData;
ALU ALU_LW_SW(.Inst(ID_EX_opcode), .ALUIn1(ALUIn1), .ALUIn2(ALUIn2), .Shift_Val(ID_EX_imm_4bit), .ALUOut(ALUOut), .Z(Z), .V(V), .N(N));

//Writing Flag Registers
assign flags_in = {Z, V, N};
assign flag_wen = (ID_EX_opcode[3:1] == 3'b000) || (ID_EX_opcode == 4'b0010) || (ID_EX_opcode == 4'b0100) || (ID_EX_opcode == 4'b0101) || (ID_EX_opcode == 4'b0110);

//Flag_br_checker
//assign flag_br_checker = ((opcode[3:1] == 3'b110) && (IF_ID_Inst[11:9] != 3'b111)) ? 1'b1 : 1'b0;

//Flag Register
//Flags flag(.flags_out(flags_out), .clk(clk), .rst(~rst_n), .wen(flag_wen), .flags_in(flags_in));

//RegWrite == 1'b0 for SW, B, BR, HLT
//assign RegWrite = ((~opcode[3]) | (~opcode[2] & ~opcode[0]) | (opcode[1] & ~opcode[0]) | (~opcode[2] & opcode[1])) ? 1'b1 : 1'b0;

assign MemWrite = (opcode == 4'b1001) ? 1'b1 : 1'b0; //1'b1 for SW
assign MemRead = (opcode == 4'b1000) ? 1'b1 : 1'b0; //1'b1 for LW
assign MemtoReg =  (opcode == 4'b1000) ? 1'b1 : 1'b0; //1'b1 for LW, similar to MemRead

//Dmem
assign data_in = (forward_mem_mux) ? DstData : EX_MEM_MemData ;
data_memory1c DMEM(.data_out(Dmem_out), .data_in(data_in), .addr(EX_MEM_ALUOut), .enable(EX_MEM_MemRead | EX_MEM_MemWrite), .wr(EX_MEM_MemWrite), .clk(clk), .rst(~rst_n));

//PC_Next adder
Adder_16bit PC_add (.A(pc), .B(16'h0002), .cin(1'b0), .Sat_Sum(next_pc), .Ovfl(pc_overflow));

//Branch adder

assign br_offset = {{6{imm_9bit[8]}}, imm_9bit, 1'b0};
Adder_16bit Br_add (.A(IF_ID_next_pc), .B(br_offset), .cin(1'b0), .Sat_Sum(branch_pc), .Ovfl(br_overflow));

//Branch or not based on opcode and br_true.
//assign pc_in = (opcode[3:1] == 3'b110) ? (opcode[0] ? (br_true ? SrcData1 : IF_ID_next_pc) : (br_true ? branch_pc : IF_ID_next_pc)) : IF_ID_next_pc;
assign pc_in = (opcode[3:1] == 3'b110) ? (opcode[0] ? (br_true ? SrcData1 : next_pc) : (br_true ? branch_pc : next_pc)) : next_pc;
//DstData storage - LW, SW, LLB, LHB, B, BR, PCS, HLT Instructions
//Nothing for SW, B, BR, HLT - because we don't need to write anything, RegWrite == 1'b0
assign LLB_LHB = (forward_in2 == 2'b00 || forward_in2 == 2'b11) ? 
			(ID_EX_opcode[0] ? (ID_EX_SrcData2 & 16'h00FF) | ID_EX_sign_extend : (ID_EX_SrcData2 & 16'hFF00) | ID_EX_sign_extend) : 
		 forward_in2 == 2'b10 ? (ID_EX_opcode[0] ? (EX_MEM_ALUOut & 16'h00FF) | ID_EX_sign_extend : (EX_MEM_ALUOut & 16'hFF00) | ID_EX_sign_extend) : 
			(ID_EX_opcode[0] ? (MEM_WB_ALUOut & 16'h00FF) | ID_EX_sign_extend : (MEM_WB_ALUOut & 16'hFF00) | ID_EX_sign_extend);
/* assign EX_MEM_ALUIn =  (ID_EX_opcode == 4'b1110) ? ID_EX_next_pc : //PCS
			(ID_EX_opcode[3:1] == 3'b101) ? (ID_EX_opcode[0] ? ((SrcData2 & 16'h00FF) | ID_EX_sign_extend) : ((SrcData2 & 16'hFF00) | ID_EX_sign_extend)): //LLB opcode - 1010, LHB opcode - 1011 
			ALUOut; */
assign EX_MEM_ALUIn =  (ID_EX_opcode == 4'b1110) ? ID_EX_next_pc : //PCS
			(ID_EX_opcode[3:1] == 3'b101) ? LLB_LHB : ALUOut;

assign DstData =  MEM_WB_MemtoReg ? MEM_WB_DmemOut : //LW
                  MEM_WB_ALUOut; //ALU Instructions - ADD, SUB, XOR, RED, PADDSB, SLL, ROR, SRA. Don't care for SW, B, BR, HLT since RegWrite == 0.

//Flag register setting
//assign Z = ((opcode[3:1] == 3'b000) & (~(|ALU_out))) 						 ? 1'b1 :
//	   ((opcode == 4'b0010) & (~(|ALU_out)))					         ? 1'b1 :
//	   (((opcode == 4'b0100) | (opcode == 4'b0101) | (opcode == 4'b0110)) & (~(|ALU_out))) ? 1'b1 : 1'b0;

//assign N = (opcode[3:1] == 3'b000) ? ALU_out[15] : flags[0];
//assign V = (opcode[3:1] == 3'b000) ? overflow	 : flags[1];

//B, BR check condition based on flags
branch_control BR1(.br_condition(br_condition), .flags_out(MEM_WB_flags), .br_true(br_true));

//HDU Instantiation
HDU HDU_01 (.IF_ID_Inst(IF_ID_Inst), .ID_EX_MemRead(ID_EX_MemRead), .ID_EX_RegWrite(ID_EX_RegWrite), .EX_MEM_RegWrite(EX_MEM_RegWrite), .EX_MEM_RdAddr(EX_MEM_RdAddr), .br_true(br_true), .MemWrite(MemWrite), .ID_EX_flag_br_checker(ID_EX_flag_br_checker), .EX_MEM_flag_br_checker(EX_MEM_flag_br_checker), .MEM_WB_flag_br_checker(MEM_WB_flag_br_checker), .ID_EX_RtAddr(ID_EX_RtAddr), .stall(stall), .IF_Flush(IF_Flush), .ID_Flush(ID_Flush), .flag_br_checker(flag_br_checker));

//module HDU (IF_ID_Inst, ID_EX_MemRead, ID_EX_RegWrite, EX_MEM_RegWrite, EX_MEM_RdAddr, br_true, ID_EX_flag_br_checker, EX_MEM_flag_br_checker, MEM_WB_flag_br_checker, ID_EX_RtAddr, ID_EX_RtAddr, stall, IF_Flush, ID_Flush);

//Pipeline Instantiation
IF_ID Init1(.clk(clk), .rst_n(rst_n), .Inst(Inst), .pc(next_pc), .IF_Flush(IF_Flush), .stall(stall), .IF_ID_Inst(IF_ID_Inst), .IF_ID_next_pc(IF_ID_next_pc), .hlt(hlt_pre), .IF_ID_hlt(IF_ID_hlt));

ID_EX Init2(.clk(clk), .rst_n(rst_n), .opcode(opcode), .SrcData1(SrcData1), .SrcData2(SrcData2), .imm_4bit(imm_4bit), .sign_extend(sign_extend), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), .DstReg(DstReg), .ID_Flush(ID_Flush), .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .MemtoReg(MemtoReg), .IF_ID_next_pc(IF_ID_next_pc), .flag_br_checker(flag_br_checker), .IF_ID_hlt(IF_ID_hlt) , 
.ID_EX_RegWrite(ID_EX_RegWrite), .ID_EX_MemRead(ID_EX_MemRead), .ID_EX_MemWrite(ID_EX_MemWrite), .ID_EX_MemtoReg(ID_EX_MemtoReg), .ID_EX_RegVal1(ID_EX_SrcData1), .ID_EX_RegVal2(ID_EX_SrcData2), .ID_EX_sign_extend(ID_EX_sign_extend), .ID_EX_RsAddr(ID_EX_RsAddr), .ID_EX_RtAddr(ID_EX_RtAddr), .ID_EX_RdAddr(ID_EX_RdAddr), .ID_EX_imm_4bit(ID_EX_imm_4bit), .ID_EX_opcode(ID_EX_opcode), .ID_EX_next_pc(ID_EX_next_pc), .ID_EX_flag_br_checker(ID_EX_flag_br_checker), .ID_EX_hlt(ID_EX_hlt));

EX_MEM Init3(.clk(clk), .rst_n(rst_n), .ID_EX_RegWrite(ID_EX_RegWrite), .ID_EX_MemRead(ID_EX_MemRead), .ID_EX_MemWrite(ID_EX_MemWrite), .ID_EX_MemtoReg(ID_EX_MemtoReg), .ALUOut(EX_MEM_ALUIn), .ID_EX_RdAddr(ID_EX_RdAddr), .MemData(ID_EX_SrcData2), .ID_EX_flag_br_checker(ID_EX_flag_br_checker), .flag_wen(flag_wen), .flags_in(flags_in), .ID_EX_hlt(ID_EX_hlt),
.EX_MEM_RegWrite(EX_MEM_RegWrite), .EX_MEM_MemRead(EX_MEM_MemRead), .EX_MEM_MemWrite(EX_MEM_MemWrite), .EX_MEM_MemtoReg(EX_MEM_MemtoReg), .EX_MEM_MemData(EX_MEM_MemData), .EX_MEM_RdAddr(EX_MEM_RdAddr), .EX_MEM_ALUOut(EX_MEM_ALUOut), .EX_MEM_flag_br_checker(EX_MEM_flag_br_checker), .EX_MEM_flags(EX_MEM_flags), .EX_MEM_hlt(EX_MEM_hlt));

MEM_WB Init4(.clk(clk), .rst_n(rst_n), .EX_MEM_RegWrite(EX_MEM_RegWrite), .EX_MEM_MemtoReg(EX_MEM_MemtoReg), .EX_MEM_ALUOut(EX_MEM_ALUOut), .Dmem_out(Dmem_out), .EX_MEM_RdAddr(EX_MEM_RdAddr), .EX_MEM_flags(EX_MEM_flags), .EX_MEM_hlt(EX_MEM_hlt), .EX_MEM_flag_br_checker(EX_MEM_flag_br_checker),
.MEM_WB_RegWrite(MEM_WB_RegWrite), .MEM_WB_MemtoReg(MEM_WB_MemtoReg), .MEM_WB_ALUOut(MEM_WB_ALUOut), .MEM_WB_DmemOut(MEM_WB_DmemOut), .MEM_WB_RdAddr(MEM_WB_RdAddr), .MEM_WB_flags(MEM_WB_flags), .MEM_WB_hlt(MEM_WB_hlt), .MEM_WB_flag_br_checker(MEM_WB_flag_br_checker));

assign sign_extend = (opcode[3:1] == 3'b101) ? (opcode[0] ? {imm_8bit, {8{1'b0}}} : {{8{1'b0}}, imm_8bit}) : ((opcode[3:1] == 3'b100) ?  {{11{imm_4bit[3]}}, imm_4bit, 1'b0} : ID_EX_SrcData2);

//forwarding_unit  forwarding_unit_01();

forwarding_unit forward(.ID_EX_Rs(ID_EX_RsAddr), .ID_EX_Rt(ID_EX_RtAddr), .MEM_WB_Rd(MEM_WB_RdAddr), .EX_MEM_Rd(EX_MEM_RdAddr),
                        .EX_MEM_RegWrite(EX_MEM_RegWrite), .EX_MEM_MemWrite(EX_MEM_MemWrite), .MEM_WB_RegWrite(MEM_WB_RegWrite), .forward_in1(forward_in1), .forward_in2(forward_in2), .forward_mem_mux(forward_mem_mux));
endmodule
