
module decoder_2to4_with_enable(
	input logic  enable,
	input logic  [1:0] in,
	output logic [3:0] decoder_output
	); 
	
	always_comb begin
		
		if(enable) 
			case(in)
				0: decoder_output<=1;	
				1: decoder_output<=2;
				2: decoder_output<=4;
				3: decoder_output<=8;
			endcase 
		
	end 
endmodule

`timescale 1ns/1ps

module decoder_2to4_with_enable_tb;
    // Declare inputs and outputs as regs and wires
    reg enable;
    reg [1:0] in;
    wire [3:0] decoder_output;

    // Instantiate the module under test
    decoder_2to4_with_enable dut (
        .enable(enable),
        .in(in),
        .decoder_output(decoder_output)
    );

    // Test stimulus
    initial begin
        // Initialize inputs
        enable = 0;
        in = 2'b00;

        // Test case 1: Enable = 0 (all outputs should be 0)
        #10; enable = 0; in = 2'b00;
        #10; enable = 0; in = 2'b01;
        #10; enable = 0; in = 2'b10;
        #10; enable = 0; in = 2'b11;

        // Test case 2: Enable = 1 (decode inputs)
        #10; enable = 1; in = 2'b00; // Should output 4'b0001
        #10; enable = 1; in = 2'b01; // Should output 4'b0010
        #10; enable = 1; in = 2'b10; // Should output 4'b0100
        #10; enable = 1; in = 2'b11; // Should output 4'b1000

        #10; $finish; // End simulation
    end

    // Monitor the inputs and outputs
    initial begin
        $monitor("Time=%0t | Enable=%b In=%b | Decoder Output=%b", $time, enable, in, decoder_output);
    end
endmodule
