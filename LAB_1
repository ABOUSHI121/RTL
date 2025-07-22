module	sr_flip_flop(
	input logic S, R, clk, 
	output logic Q, Q_
);							    

	always_ff @(posedge clk)begin
	
	   unique case ({S,R})
		1 : begin
				Q	<=	1'b0; 
				Q_	<=	1'b1;
			end
		
		2 : begin
				Q	<=	1'b1; 
				Q_	<=	1'b0;
			end 
		
		3 : begin
				Q	<=	1'bx; 
				Q_	<=	1'bx;
			end    
		
	   endcase
	   
	   
	end
	
endmodule	

module sr_flip_flop_test;

    // Signals
    
    bit clk;  
    logic  S, R;
    logic Q;
    logic Q_;

    `define PERIOD 10
    always
    #(`PERIOD/2) clk <= ~clk;
  
    // Instantiate SR flip-flop module
    sr_flip_flop dut (
        .S(S),
        .R(R),		  
		.clk(clk),
        .Q(Q),
        .Q_(Q_)
    );

    // Test stimulus
    initial begin
        $dumpfile("simulation.vcd"); // Specify the dumpfile name
        $dumpvars(0, sr_flip_flop_test); // Dump all signals in tb_waveform module
        // Initialize inputs
        S = 0; R = 0;
        
        // Test case 1: Reset
        #10 S = 0; R = 1;
        #10 S = 0; R = 0;
        
        // Test case 2: Set
        #10 S = 1; R = 0;
        #10 S = 0; R = 0;
        
        // Test case 3: Invalid state
        #10 S = 1; R = 1;
        #10 S = 0; R = 0;
        
        // Test case 4: Hold state
        #10 S = 0; R = 0;
        
        // End simulation
        #10 $finish;
    end
    
    // Display outputs
    always @(posedge clk) begin
      $display("Time: %t, S: %b, R: %b, Q: %b, Q_:%b", $time, S, R, Q, Q_);
      $display("----------------------------------------------------------");
    end

endmodule
