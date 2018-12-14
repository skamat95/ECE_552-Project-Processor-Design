module branch_control (br_condition, flags_out, br_true);

input [2:0] br_condition;
input [2:0] flags_out;
output reg br_true;

//B, BR check condition based on flags
always @* begin
case(br_condition)
3'b000: begin
 br_true = (flags_out[2] == 0) ? 1'b1 : 1'b0;
 end
3'b001: begin
 br_true = (flags_out[2] == 1) ? 1'b1 : 1'b0; 
 end
3'b010: begin
 br_true = ((flags_out[2] == 0) & (flags_out[0] ==0)) ? 1'b1 : 1'b0; 
 end
3'b011: begin
 br_true = (flags_out[0] == 1) ? 1'b1 : 1'b0; 
 end
3'b100: begin
 br_true = ((flags_out[2] == 1) | ((flags_out[2] == 0) & (flags_out[0] ==0)))? 1'b1 : 1'b0; 
 end
3'b101: begin
 br_true = ((flags_out[0] == 1) | (flags_out[2] == 1)) ? 1'b1 : 1'b0; 
 end
3'b110: begin
 br_true = (flags_out[1] == 1) ? 1'b1 : 1'b0; 
 end
3'b111: begin
 br_true = 1'b1; 
 end
default: br_true = 1'b0;
endcase
end

endmodule
