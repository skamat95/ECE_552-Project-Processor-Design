//Cache structure: 64 sets selected by BlockEnable. BlockEnable_0 for way 0 and BlockEnable_1 for way1.

//16 bit blocks
module MDA_DA_Cache(clk, rst, Data_Tag, Shift_out, data_addr, write_tag_array, Mem_write, DataIn_DA, write_data_array, miss_data_cache, DataOut_DA);
input clk;
input rst;
input [5:0] Data_Tag; //LRU, valid, tag
input [63:0] Shift_out; //from Shifter_128bit
input [15:0] data_addr; //Address for Tag and Set bits
wire [63:0] BlockEnable_0; //Blockenables for Set0 and Set1 of MetaData Array
wire [63:0] BlockEnable_1;
wire [15:0] DataOut; //Output of Metadata Array
input write_tag_array; //From CMC
input Mem_write;
reg Lru_en;  //Only in case of hit, to write LRU bit of metadata array
reg hit;
reg [15:0] DataIn;
reg Write_en; //For metadata array
reg offset; //Tells which block is hit
output reg miss_data_cache; //Final output
//Data array stuff
input [15:0] DataIn_DA;
input write_data_array;
wire Write_en_DA;
wire [63:0] BlockEnable_0_DA;
wire [63:0] BlockEnable_1_DA;
wire [7:0] WordEnable_DA;
output [15:0] DataOut_DA;

MetaDataArray MDA1(.clk(clk), .rst(~rst), .DataIn(DataIn), .Write(Write_en), .Lru_en(Lru_en), .BlockEnable_0(BlockEnable_0), .BlockEnable_1(BlockEnable_1), .DataOut(DataOut));
DataArray DA1(.clk(clk), .rst(~rst), .DataIn(DataIn_DA), .Write(Write_en_DA), .BlockEnable_0(BlockEnable_0_DA), .BlockEnable_1(BlockEnable_1_DA), .offset(offset), .WordEnable(WordEnable_DA), .DataOut(DataOut_DA));

//Block enables for MDA. Redundant here, inputs to different blocks in MDA file.
assign BlockEnable_0 = Shift_out;
assign BlockEnable_1 = Shift_out;

//Blockenables for DA.
assign BlockEnable_0_DA = offset ? 64'h0000000000000000 : Shift_out;
assign BlockEnable_1_DA = !offset ? 64'h0000000000000000 : Shift_out;
//Word enable for choosing block in DA. One hot.
word_decoder WD1(.addr(data_addr[3:1]), .word_enable(WordEnable_DA));
assign Write_en_DA = hit ? Mem_write : write_data_array;

always @ (rst, data_addr, write_tag_array, write_data_array, Mem_write, BlockEnable_1_DA, BlockEnable_0_DA, Shift_out) begin 
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
