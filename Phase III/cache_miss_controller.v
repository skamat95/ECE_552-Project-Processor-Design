module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array, Write_addr, 
			write_tag_array,main_memory_address, memory_address, memory_data_valid);

input clk, rst_n;
input miss_detected; // active high when tag match logic detects a miss
input [15:0] miss_address; // address that missed the cache
output reg fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
output reg write_data_array; // write enable to cache data array to signal when filling with memory_data
output reg write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array
output [15:0] main_memory_address; // address to read from memory
output [15:0] memory_address; // cache address to write the data from memory
input memory_data_valid; // active high indicates valid data returning on memory bus
input [15:0]Write_addr;

///////////////////////////////////Local parameters for state machine ////////////////////////////////////////////////////

localparam IDLE = 1'b0;
localparam WAIT = 1'b1;


/////////////////////////////////// Internal Wires ///////////////////////////////////////////////////////////////////////

wire STATE;
reg nxt_STATE;
reg en_cnt, clr_cnt;
wire [3:0]cnt, inc_cnt, cnt_ff;
wire [7:0]decoded_write_enable;
reg WordEnable;
wire mem_Write;
//////////////////////////////////// Logic ////////////////////////////////////////////////////////////////////////////////

// STATE FLOP

dff state(.q(STATE), .d(nxt_STATE), .wen(1'b1), .clk(clk), .rst(~rst_n));

// 4 bit Counter - to count number of chunks received 

//assign cnt_ff = (clr_cnt) ? 4'h0 : (en_cnt) ? inc_cnt : cnt ; 
assign cnt_ff = (clr_cnt) ? 4'h0 : inc_cnt;
dff counter[3:0](.q(cnt), .d(cnt_ff), .wen(en_cnt || clr_cnt || miss_detected), .clk(clk), .rst(~rst_n));
adder_4bit_josh chunks(.AA(cnt), .BB(4'b0001), .SS(inc_cnt), .CC());

// Memory address increment //////////////////////////////////////////////////////////

assign main_memory_address = 	(miss_detected) ? (cnt == 4'h0) ? {{miss_address[15:4]},4'b0000} :  // to be used when instatntitating multi cycle memory
			     	(cnt == 4'h1) ? {{miss_address[15:4]},4'b0010} : 
			    	(cnt == 4'h2) ? {{miss_address[15:4]},4'b0100} :
				(cnt == 4'h3) ? {{miss_address[15:4]},4'b0110} :
				(cnt == 4'h4) ? {{miss_address[15:4]},4'b1000} :
				(cnt == 4'h5) ? {{miss_address[15:4]},4'b1010} :
				(cnt == 4'h6) ? {{miss_address[15:4]},4'b1100} :
				(cnt == 4'h7) ? {{miss_address[15:4]},4'b1110} : 16'h0000 : Write_addr;

assign memory_address = 	(cnt == 4'h4) ? {{miss_address[15:4]},4'b0000} : // to be used when writing to cache, passed on to other module as output
			    	(cnt == 4'h5) ? {{miss_address[15:4]},4'b0010} :
				(cnt == 4'h6) ? {{miss_address[15:4]},4'b0100} :
				(cnt == 4'h7) ? {{miss_address[15:4]},4'b0110} :
				(cnt == 4'h8) ? {{miss_address[15:4]},4'b1000} :
				(cnt == 4'h9) ? {{miss_address[15:4]},4'b1010} :
				(cnt == 4'ha) ? {{miss_address[15:4]},4'b1100} : 
				(cnt == 4'hb) ? {{miss_address[15:4]},4'b1110} : 16'h0000;


// Combinational Logic //////////////////////////////////////////////////////////////////////////////////////
always @* begin
  nxt_STATE = IDLE;
  write_tag_array = 1'b0;
  write_data_array = 1'b0;
  fsm_busy = 1'b0;
  en_cnt = 1'b0;
  WordEnable = 8'h00;	
  clr_cnt = 1'b0;
 case (STATE)
	IDLE : begin	
		clr_cnt = 1'b1;				
		case (miss_detected)
		  1'b1: begin			// in case of miss detected in idle state
			clr_cnt = 1'b0;
			fsm_busy = 1'b1;
			nxt_STATE = WAIT;
			end   // for miss detected 
		  default: nxt_STATE = IDLE;
			endcase		// for miss detect
		end 		// for IDLE

	WAIT : begin
		fsm_busy = 1'b1;
		  case (cnt)
			4'hb: begin
			  clr_cnt = 1'b1;
			  nxt_STATE = IDLE ;
			  write_tag_array = 1'b1;	
			  write_data_array = 1'b1;
			end

			default : begin
			  nxt_STATE = WAIT;
				case (memory_data_valid)	
				  1'b1: begin
					write_data_array = 1'b1;		
					en_cnt = 1'b1;
					end
				  default :  begin
					write_data_array = 1'b0;	
					en_cnt = 1'b0;
					end
				endcase	
			end
		  endcase	// for nested case 
		end		// for WAIT
	default : nxt_STATE = IDLE;

endcase
end
endmodule
