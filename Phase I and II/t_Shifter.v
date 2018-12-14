module t_Shifter();
 	reg signed [15:0] stim_shift_in;
        reg [3:0] stim_shift_val;
        reg stim_mode;
	wire signed [15:0] stim_shift_out; 
	integer i;

	// instantiate UUT
	Shifter iDUT_Shifter(.Shift_Out(stim_shift_out), .Shift_In(stim_shift_in), .Shift_Val(stim_shift_val), .Mode(stim_mode));
	
	// monitor statement
	initial $monitor("%t:Shift_Out=%b Shift_In=%b Shift_Val=%b Mode=%b",$time, stim_shift_out, stim_shift_in, stim_shift_val, stim_mode);

	// stimulus generation
	initial begin
           for (i = 0; i<10; i = i+1) begin
             stim_mode = $random;   
             stim_shift_in[15:0]= $random;
             stim_shift_val[3:0]= $random;
	     #10;
             if ((stim_mode == 1'b0) && (stim_shift_out == stim_shift_in << stim_shift_val))
	    $display("Correct Shift-left");
             else if ((stim_mode == 1'b1) && (stim_shift_out == stim_shift_in >>> stim_shift_val))
            $display("Correct Shift-right arithmetic");
          else 
            $display("Incorrect Shift");
          end
         #10 $stop;
	end
endmodule
