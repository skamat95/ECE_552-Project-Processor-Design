//Data Array instantiations


module Data_cache(clk, rst, DataIn, Shift_out, miss_data_cache, data_addr);
input clk;
input rst;
input [15:0] data_addr;
input [7:0] DataIn; //LRU, valid, tag
reg Write_en;
input [127:0] Shift_out; //from Shifter_128bit
output reg miss_data_cache;
reg [7:0] DataIn_imm;
wire [7:0] DataOut;
reg hit;
reg BlockEnable;
//wire sel;

//assign BlockEnable = sel ? Shift_out : Shift_Out_two;
MetaDataArray MDH(.clk(clk), .rst(rst), .DataIn(DataIn_imm), .Write(Write_en), .BlockEnable(BlockEnable), .DataOut(DataOut));


assign Shift_Out_two = Shift_out << 1;
always @ (data_addr) begin
BlockEnable = Shift_out;
Write_en = 1'b0;

case((DataOut[6] == 1'b1) && (DataOut[5:0] == DataIn[5:0])) //Valid and tag is equal
	1'b1: begin hit = 1'b1;
	DataIn_imm = {1'b0, 1'b1, DataIn[5:0]};
	Write_en = 1'b1;
	end
	1'b0: begin
		BlockEnable = Shift_Out_two;
	case((DataOut[6] == 1'b1) && (DataOut[5:0] == DataIn[5:0]))
		1'b1: begin hit = 1'b1;
			DataIn_imm = {1'b0, 1'b1, DataIn[5:0]};
			Write_en = 1'b1;
			end
		1'b0: miss_data_cache = 1'b1;
	endcase
		end
endcase
end //for always

DataArray(.clk(clk), .rst(rst), input [15:0] DataIn, .Write(Write_en_data_array), .BlockEnable(BlockEnable), input [7:0] WordEnable, output [15:0] DataOut);

endmodule




