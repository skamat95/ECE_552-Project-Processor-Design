module word_decoder(addr, word_enable);

input[2:0] addr; 
output reg [7:0] word_enable;

always @(addr) begin
	case(addr)
		3'h0: word_enable = 8'h01;
		3'h1: word_enable = 8'h02;
		3'h2: word_enable = 8'h04;
		3'h3: word_enable = 8'h08;
		3'h4: word_enable = 8'h10;
		3'h5: word_enable = 8'h20;
		3'h6: word_enable = 8'h40;
		3'h7: word_enable = 8'h80;
		default: word_enable = 8'h00;
	endcase
end
endmodule