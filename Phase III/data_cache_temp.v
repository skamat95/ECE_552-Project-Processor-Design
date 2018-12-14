//Data Array instantiations

/*
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
DataArray DA0(.clk(clk), .rst(rst), .DataIn(DataIn_DA), .Write(Write_en_DA), .BlockEnable(BlockEnable_DA), .WordEnable(WordEnable_DA), .DataOut(DataOut_DA));
endmodule
*/

//16 bit blocks
module Data_cache(clk, rst, Data_Tag, Shift_out, write_tag_array, Mem_write, DataIn_DA, write_data_array, miss_data_cache, data_addr, DataOut_DA);
input clk;
input rst;
input [5:0] Data_Tag; //LRU, valid, tag
input [63:0] Shift_out; //from Shifter_128bit
input [15:0] data_addr;
wire [63:0] BlockEnable_0; //Blockenables for Set0 and Set1 of MetaData Array
wire [63:0] BlockEnable_1;
wire [15:0] DataOut;
input write_tag_array;
input Mem_write;

assign BlockEnable_0 = Shift_out;
assign BlockEnable_1 = Shift_out;
//assign BlockEnable = Shift_out | (Shift_out << 1);
//wire [1:0] hit;
reg Lru_en;
reg hit;
reg [15:0] DataIn;
reg Write_en;
reg offset; //Tells which block is hit
output reg miss_data_cache;
//Data array stuff
input [15:0] DataIn_DA;
input write_data_array;
wire Write_en_DA;
wire [63:0] BlockEnable_0_DA;
wire [63:0] BlockEnable_1_DA;
wire [7:0] WordEnable_DA;
output [15:0] DataOut_DA;

MetaDataArray_Data MDA1(.clk(clk), .rst(~rst), .DataIn(DataIn), .Write(Write_en), .Lru_en(Lru_en), .BlockEnable_0(BlockEnable_0), .BlockEnable_1(BlockEnable_1), .DataOut(DataOut));
DataArray DA1(.clk(clk), .rst(~rst), .DataIn(DataIn_DA), .Write(Write_en_DA), .BlockEnable_0(BlockEnable_0_DA), .BlockEnable_1(BlockEnable_1_DA), .offset(offset), .WordEnable(WordEnable_DA), .DataOut(DataOut_DA));

/*
assign hit = (DataOut [14] & (DataOut[13:8] == Data_Tag)) ? 2'b10 : (DataOut[6] & (DataOut[5:0] == Data_Tag)) ? 2'b01 : 2'b00;
assign DataIn = (hit == 2'b10) ? {1'b0, DataOut[14:8], 1'b1, DataOut[6:0]} :
                (hit == 2'b01) ? {1'b1, DataOut[14:8], 1'b0, DataOut[6:0]} :
                (DataOut[14] == 0) ? {1'b0, 1'b1, Data_Tag, 1'b1, DataOut[6:0]} :
                (DataOut[6] == 0) ? {1'b1, DataOut[14:8], 1'b0, 1'b1, Data_Tag} :
                (DataOut[15] == 1) ? {1'b0, 1'b1, Data_Tag, 1'b1, DataOut[6:0]} :
                {1'b1, DataOut[14:8], 1'b0, 1'b1, Data_Tag};
                
assign Write_en = ((hit == 2'b10) | (hit == 2'b01)) ? 1'b1 : write_tag_array;
*/

//assign BlockEnable_DA = offset ? Shift_out : (Shift_out << 1);
//assign BlockEnable_DA = Shift_out;
//assign mem_address = hit ? data_addr : miss_address;
word_decoder WD1(.addr(data_addr[3:1]), .word_enable(WordEnable_DA));
assign Write_en_DA = hit ? Mem_write : write_data_array;

assign BlockEnable_0_DA = offset ? 64'h0000000000000000 : Shift_out;
assign BlockEnable_1_DA = !offset ? 64'h0000000000000000 : Shift_out;

always @ (rst, data_addr, write_tag_array, write_data_array, Mem_write, BlockEnable_1_DA, BlockEnable_0_DA, Shift_out) begin    //Think about default of case statements
miss_data_cache = 1'b0;
offset = 1'b0;
Lru_en = 1'b0;
Write_en = 1'b0;
hit = 1'b0;
 case(DataOut[14] && (DataOut[13:8] == Data_Tag))
   1'b1:  begin hit = 1'b1;
          DataIn = {1'b0, DataOut[14:8], 1'b1, DataOut[6:0]};
          Lru_en = 1'b1;
	  offset = 1'b1; //Hit in Block 1
          end
   1'b0:  begin
          case(DataOut[6] && (DataOut[5:0] == Data_Tag))
            1'b1: begin 
		hit = 1'b1;
            	DataIn = {1'b1, DataOut[14:8], 1'b0, DataOut[6:0]};
           	Lru_en = 1'b1;
		offset = 1'b0; //Hit in Block 0
                
            end
            1'b0: begin
            	miss_data_cache = 1'b1;
            	Write_en = write_tag_array;
            		case(DataOut[14])  // check the valid bit of Block 1
              			1'b0: begin
					DataIn = {1'b0, 1'b1, Data_Tag, 1'b1, DataOut[6:0]};
					offset = 1'b1;
					end
             		 	1'b1: begin
                		     case(DataOut[15])	// check the lru if valid is 1 for block 1
                			     1'b1: 
						begin
						DataIn = {1'b0, 1'b1, Data_Tag, 1'b1, DataOut[6:0]};		// if this is lru then evict
						offset = 1'b1;
						
						end
                			     1'b0: 
						begin
						DataIn = {1'b1, DataOut[14:8], 1'b0, 1'b1, Data_Tag};	// if this is not lru then irrespective of valid bit evict the other block
						offset = 1'b0;
						end
                    			endcase
                   			end
                endcase
              end
            endcase
          end
        endcase 
end //for always

endmodule
