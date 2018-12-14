`timescale 1ns/1ns
module t_addsub_4bit();
 	reg signed [15:0] stim_A;
	reg signed [15:0] stim_B;
        reg stim_cin;
        wire signed [15:0] hw_Sum; 
        wire hw_Ovfl;
	integer i, S1, S2;

	// instantiate UUT
	cla_16bit iDUT(.A(stim_A[15:0]), .B(stim_B[15:0]), .cin(stim_cin), .Sat_Sum(hw_Sum), .Ovfl(hw_Ovfl));
	
	// monitor statement
	initial $monitor("%t:A=%b B=%b sub=%b Sum=%b hw_Ovfl=%b",$time, stim_A[15:0], stim_B[15:0], stim_cin, hw_Sum, hw_Ovfl);

	// stimulus generation
	initial begin 	// stimulus generation
     for (i = 0; i<10; i = i+1) begin
		stim_A = $random;
                stim_B = $random;
                stim_cin = $random;
		#5;
          S1 = $signed(stim_A[15:0]) + $signed(stim_B[15:0]);
          S2 = $signed(stim_A[15:0]) - $signed(stim_B[15:0]);
	  if ((stim_cin == 0) && (S1 == $signed(hw_Sum[15:0])) && hw_Ovfl == 1'b0)
	    $display("correct add");
	  else if ((stim_cin == 1) && (S2 == $signed(hw_Sum[15:0])) && hw_Ovfl == 1'b0)
	    $display("correct subtract");
	  else if ((stim_cin == 0) && (S1 != $signed(hw_Sum[15:0])) && hw_Ovfl == 1'b1)
	    $display("overflow add");
	  else if ((stim_cin == 1) && (S2 != $signed(hw_Sum[15:0])) && hw_Ovfl == 1'b1)
	    $display("overflow subtract");
	  else $display("error");
	    end
         #10 $stop;
	end
endmodule

