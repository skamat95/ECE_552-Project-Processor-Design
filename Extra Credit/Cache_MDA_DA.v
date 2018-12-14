//Cache structure: 64 sets selected by BlockEnable. BlockEnable_0 for way 0 and BlockEnable_1 for way1.

//16 bit blocks
module MDA_DA_Cache(clk, rst, Data_Tag, Shift_out, data_addr, write_tag_array, Mem_write, DataIn_DA, write_data_array, miss_data_cache, DataOut_DA);
input clk;
input rst;
input [31:0] Shift_out;
input [6:0] Data_Tag; //LRU, valid, tag
input [15:0] data_addr; //Address for Tag and Set bits
wire [31:0] BlockEnable; //Blockenable for  MetaData Array
wire [39:0] DataOut; //Output of Metadata Array
input write_tag_array; //From CMC
input Mem_write;
reg Lru_en;  //Only in case of hit, to write LRU bit of metadata array
reg hit;
reg [39:0] DataIn;
reg Write_en; //For metadata array
reg [1:0] offset; //Tells which block is hit
output reg miss_data_cache; //Final output
//Data array stuff
input [15:0] DataIn_DA;
input write_data_array;
wire Write_en_DA;
wire [31:0] BlockEnable_0_DA;
wire [31:0] BlockEnable_1_DA;
wire [31:0] BlockEnable_2_DA;
wire [31:0] BlockEnable_3_DA;
wire [7:0] WordEnable_DA;
output [15:0] DataOut_DA;

MetaDataArray MDA1(.clk(clk), .rst(~rst), .DataIn(DataIn), .Write(Write_en), .Lru_en(Lru_en), .BlockEnable(BlockEnable), .DataOut(DataOut));
DataArray DA1(.clk(clk), .rst(~rst), .DataIn(DataIn_DA), .Write(Write_en_DA), .BlockEnable_0(BlockEnable_0_DA), .BlockEnable_1(BlockEnable_1_DA), .BlockEnable_2(BlockEnable_2_DA), .BlockEnable_3(BlockEnable_3_DA), .WordEnable(WordEnable_DA), .DataOut(DataOut_DA));

//Block enables for MDA. Redundant here, inputs to different blocks in MDA file.
assign BlockEnable = Shift_out;

reg cache_error;
//Blockenables for DA.
assign BlockEnable_0_DA = (offset == 2'b00) ? Shift_out : 64'h0000000000000000;
assign BlockEnable_1_DA = (offset == 2'b01) ? Shift_out : 64'h0000000000000000;
assign BlockEnable_2_DA = (offset == 2'b10) ? Shift_out : 64'h0000000000000000;
assign BlockEnable_3_DA = (offset == 2'b11) ? Shift_out : 64'h0000000000000000;

//Word enable for choosing block in DA. One hot.
word_decoder WD1(.addr(data_addr[3:1]), .word_enable(WordEnable_DA));
assign Write_en_DA = hit ? Mem_write : write_data_array;

always @ (rst, data_addr, write_tag_array, write_data_array, Mem_write, BlockEnable_0_DA, BlockEnable_1_DA, BlockEnable_2_DA, BlockEnable_3_DA, Shift_out) begin    //Think about default of case statements
miss_data_cache = 1'b0;
offset = 2'b00;
Lru_en = 1'b0;
Write_en = 1'b0;
hit = 1'b0;
cache_error = 1'b0;
 case({DataOut[37],(DataOut[36:30] == Data_Tag)})
   2'b11: begin hit = 1'b1;
          Lru_en = 1'b1;
	  offset = 2'b11; //Hit in Block 11
	  DataIn[39:38] = 2'b00; //Hit block LRU = 00
	  if(DataOut[29:28] < DataOut[39:38]) DataIn[29:28] = DataOut[29:28] + 1'b1;
	  if(DataOut[19:18] < DataOut[39:38]) DataIn[19:18] = DataOut[19:18] + 1'b1;
	  if(DataOut[9:8] < DataOut[39:38]) DataIn[9:8] = DataOut[9:8] + 1'b1;
          end
   2'b10:  begin
         	if(DataOut[27] && (DataOut[26:20] == Data_Tag))
         	begin 
		hit = 1'b1;
            	DataIn[29:28] = 2'b00;
           	Lru_en = 1'b1;
		offset = 2'b10; //Hit in Block 10
                if(DataOut[39:38] < DataOut[29:28]) DataIn[39:38] = DataOut[39:38] + 1'b1;
	  	if(DataOut[19:18] < DataOut[29:28]) DataIn[19:18] = DataOut[19:18] + 1'b1;
	  	if(DataOut[9:8] < DataOut[29:28]) DataIn[9:8] = DataOut[9:8] + 1'b1;
            	end
		end
    2'b01: begin
		if(DataOut[17] && (DataOut[16:10] == Data_Tag))
		begin
		hit = 1'b1;
            	DataIn[19:18] = 2'b00;
           	Lru_en = 1'b1;
		offset = 2'b01; //Hit in Block 10
                if(DataOut[39:38] < DataOut[19:18]) DataIn[39:38] = DataOut[39:38] + 1'b1;
	  	if(DataOut[29:28] < DataOut[19:18]) DataIn[29:28] = DataOut[29:28] + 1'b1;
	  	if(DataOut[9:8] < DataOut[19:18]) DataIn[9:8] = DataOut[9:8] + 1'b1;
		end
		end
     2'b00: begin
		if(DataOut[7] && (DataOut[6:0] == Data_Tag))
		begin
		hit = 1'b1;
            	DataIn[9:8] = 2'b00;
           	Lru_en = 1'b1;
		offset = 2'b00; //Hit in Block 00
                if(DataOut[39:38] < DataOut[9:8]) DataIn[39:38] = DataOut[39:38] + 1'b1;
	  	if(DataOut[29:28] < DataOut[9:8]) DataIn[29:28] = DataOut[29:28] + 1'b1;
	  	if(DataOut[19:18] < DataOut[9:8]) DataIn[19:18] = DataOut[19:18] + 1'b1;
		end
		end
	default: //miss in all 4
		begin
            	miss_data_cache = 1'b1;
            	Write_en = write_tag_array;
		casex({DataOut[37], DataOut[27], DataOut[17], DataOut[7]}) //Valid of Blocks
	4'b0xxx: //Replace 11
		begin
		DataIn[39:38] = 2'b00; //New LRU
		DataIn[29:28] = DataOut[29:28] + 1'b1;
		DataIn[19:18] = DataOut[19:18] + 1'b1;
		DataIn[9:8] = DataOut[9:8] + 1'b1;
		end
	4'b10xx: //Replace 10
		begin
		DataIn[29:28] = 2'b00; //New LRU
		DataIn[39:38] = DataOut[39:38] + 1'b1;
		DataIn[19:18] = DataOut[19:18] + 1'b1;
		DataIn[9:8] = DataOut[9:8] + 1'b1;
		end
	4'b110x: //Replace 01
		begin
		DataIn[19:18] = 2'b00; //New LRU
		DataIn[39:38] = DataOut[39:38] + 1'b1;
		DataIn[29:28] = DataOut[29:28] + 1'b1;
		DataIn[9:8] = DataOut[9:8] + 1'b1;
		end
	4'b1110: //Replace 00
		begin
		DataIn[9:8] = 2'b00; //New LRU
		DataIn[39:38] = DataOut[39:38] + 1'b1;
		DataIn[29:28] = DataOut[29:28] + 1'b1;
		DataIn[19:18] = DataOut[19:18] + 1'b1;
		end
	4'b1111: //Check LRUs
		casex({DataOut[39:38],DataOut[29:28], DataOut[19:18], DataOut[9:8]})
		8'b11xxxxxx: //Replace 11
			begin
			DataIn[39:38] = 2'b00; //New LRU
			DataIn[29:28] = DataOut[29:28] + 1'b1;
			DataIn[19:18] = DataOut[19:18] + 1'b1;
			DataIn[9:8] = DataOut[9:8] + 1'b1;
			end
		8'bxx11xxxx: //Replace 10
			begin
			DataIn[29:28] = 2'b00; //New LRU
			DataIn[39:38] = DataOut[39:38] + 1'b1;
			DataIn[19:18] = DataOut[19:18] + 1'b1;
			DataIn[9:8] = DataOut[9:8] + 1'b1;
			end
		8'bxxxx11xx: //Replace 01
			begin
			DataIn[19:18] = 2'b00; //New LRU
			DataIn[39:38] = DataOut[39:38] + 1'b1;
			DataIn[29:28] = DataOut[29:28] + 1'b1;
			DataIn[9:8] = DataOut[9:8] + 1'b1;
			end
		8'bxxxxxx11: //Replace 00
			begin
			DataIn[9:8] = 2'b00; //New LRU
			DataIn[39:38] = DataOut[39:38] + 1'b1;
			DataIn[29:28] = DataOut[29:28] + 1'b1;
			DataIn[19:18] = DataOut[19:18] + 1'b1;
			end
		default: cache_error = 1'b1;
		endcase
	default: cache_error = 1'b1;
	endcase
	end
	endcase
			
			
end //for always

endmodule
