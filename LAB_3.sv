module whole_system(
	input logic  enable,
    input logic  [2:0] a,
    input logic  [2:0] b,
    output logic [3:0] out
	);		
	wire [1:0]out_comp_in_decoder;
	
    comparator_3bit_with_enable comp_inst (
        .enable(enable),
        .a(a),
        .b(b),
        .comparator_output(out_comp_in_decoder)
    );		
	
	decoder_2to4_with_enable decoder_inst (
        .enable(enable),
        .in(out_comp_in_decoder),
        .decoder_output(out)
    );
	
	
endmodule 


module comparator_3bit_with_enable (
    input logic  enable,
    input logic  [2:0] a,
    input logic  [2:0] b,
    output logic [1:0] comparator_output
);
    logic [2:0] temp;

    always_comb begin
        if (enable) begin
            temp = a - b;
            if (temp == 0)
                comparator_output = 2'b00; 
            else if (temp < a)
                comparator_output = 2'b01; 
            else
                comparator_output = 2'b10; 
        end else begin
            comparator_output = 2'b00; 
        end
    end
endmodule			 

`timescale 1ns/1ps

module comparator_3bit_with_enable_tb;
    // Declare inputs and outputs as regs and wires
    reg enable;
    reg [2:0] a;
    reg [2:0] b;
    wire [1:0] comparator_output;

    // Instantiate the module under test
    comparator_3bit_with_enable dut (
        .enable(enable),
        .a(a),
        .b(b),
        .comparator_output(comparator_output)
    );

    // Test stimulus
    initial begin
        // Initialize inputs
        enable = 0;
        a = 3'b000;
        b = 3'b000;

        // Test case 1: Enable = 0
        #10; enable = 0; a = 3'b001; b = 3'b010;

        // Test case 2: Enable = 1, various comparisons
        #10; enable = 1; a = 3'b000; b = 3'b000; // Equal
        #10; enable = 1; a = 3'b001; b = 3'b010; // a < b
        #10; enable = 1; a = 3'b010; b = 3'b001; // a > b
        #10; enable = 1; a = 3'b111; b = 3'b111; // Equal (max value)
        #10; enable = 1; a = 3'b100; b = 3'b011; // a > b (with borrow)

        #10; $finish; // End simulation
    end

    // Monitor the inputs and outputs
    initial begin
        $monitor("Time=%0t | Enable=%b A=%b B=%b | Output=%b", $time, enable, a, b, comparator_output);
    end
endmodule		  

`timescale 1ns/1ps

module whole_system_tb;
    // Declare inputs and outputs as regs and wires
    reg enable;
    reg [2:0] a;
    reg [2:0] b;
    wire [3:0] out;

    // Instantiate the module under test
    whole_system dut (
        .enable(enable),
        .a(a),
        .b(b),
        .out(out)
    );

    // Test stimulus
    initial begin
        // Initialize inputs
        enable = 0;
        a = 3'b000;
        b = 3'b000;

        // Test case 1: Enable = 0
        #10; enable = 0; a = 3'b001; b = 3'b010;

        // Test case 2: Enable = 1, various comparisons
        #10; enable = 1; a = 3'b000; b = 3'b000; // Equal
        #10; enable = 1; a = 3'b001; b = 3'b010; // a < b
        #10; enable = 1; a = 3'b010; b = 3'b001; // a > b
        #10; enable = 1; a = 3'b111; b = 3'b111; // Equal (max value)
        #10; enable = 1; a = 3'b100; b = 3'b011; // a > b (with borrow)

        #10; $finish; // End simulation
    end

    // Monitor the inputs and outputs
    initial begin
        $monitor("Time=%0t | Enable=%b A=%b B=%b | Out=%b", $time, enable, a, b, out);
    end
endmodule		  


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
