module forwarding_unit(ID_EX_Rs, ID_EX_Rt, MEM_WB_Rd, EX_MEM_Rd,
                        EX_MEM_RegWrite, EX_MEM_MemWrite, MEM_WB_RegWrite, forward_in1, forward_in2, forward_mem_mux);

input [3:0]ID_EX_Rs, ID_EX_Rt, MEM_WB_Rd, EX_MEM_Rd;
input EX_MEM_RegWrite, EX_MEM_MemWrite, MEM_WB_RegWrite;
output [1:0]forward_in1, forward_in2;
output forward_mem_mux;


/////////////// EX to EX forwarding //////////////////////////////////////////////
assign forward_in1 = ((EX_MEM_RegWrite) && (|EX_MEM_Rd != 1'b0) && (EX_MEM_Rd == ID_EX_Rs)) ? 2'b10 :
			((MEM_WB_RegWrite) && (|MEM_WB_Rd != 1'b0) && (MEM_WB_Rd == ID_EX_Rs)) ? 2'b01 : 2'b00;


assign forward_in2 = ((EX_MEM_RegWrite) && (|EX_MEM_Rd != 1'b0) && (EX_MEM_Rd == ID_EX_Rt)) ? 2'b10 :
			((MEM_WB_RegWrite) && |MEM_WB_Rd != 1'b0 && (MEM_WB_Rd == ID_EX_Rt)) ? 2'b01 : 2'b00;

/////////////// MEM to MEM forwarding //////////////////////////////////////////////
assign forward_mem_mux = (EX_MEM_MemWrite && MEM_WB_RegWrite && (|MEM_WB_Rd != 1'b0) && (MEM_WB_Rd == EX_MEM_Rd)) ? 1: 0;

endmodule
