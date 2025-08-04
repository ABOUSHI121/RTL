///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mul.sv
// Title       : Multiplier Module
// Project     : SystemVerilog Training
// Created     : 2024-4-2
// Description : Defines the Multiplier module
// Notes       :
// Synchronous Multiplier Design
// Specification:

///////////////////////////////////////////////////////////////////////////

module multiplier(
  	mul_intf intf
);	  

  
  always@(posedge intf.clk or posedge intf.rst) begin 
    if(intf.rst) begin 
      intf.out <= 0;
      intf.ack <= 0;
    end
    else if(intf.en) begin
      intf.out <= intf.a * intf.b;
      intf.ack <= 1;	  
    end
    else intf.ack <= 0;
  end
endmodule







interface mul_intf(clk, rst);
	input logic		clk,rst;		
	logic [7:0]		a,b;
	logic [15:0]	out;
	logic 			en, ack;
	
	modport master	(	input 	ack, out, 
						output 	clk, rst, a, b, en);
	modport slave	(	input 	clk, rst, en, a, b,
						output	out, ack);	 
	
endinterface	  









module tb_top();
    logic [7:0]  a, b;
    logic [15:0] out;
    logic        clk, rst, en, ack;

    // Instantiate the interface and multiplier
    mul_intf intf(.clk(clk), .rst(rst));
    multiplier mul(.intf);

    // Clock generation
    always begin
        #5 clk <= ~clk;	
		intf.a <= a;
		intf.b <= b;
		intf.en <= en;

		
		out <= intf.out;	   
		ack <= intf.ack;

    end

    // Test procedure
    initial begin
        // Initialize signals
        clk <= 0;
        rst <= 1;
        en  <= 0;
        a   <= 0;
        b   <= 0;
        #10;

        // Release reset
        rst <= 0;

        // Test case 1: 10 * 2 = 20
        a   <= 8'd10;
        b   <= 8'd2;
        en  <= 1;
        @(posedge clk); // Wait for multiplier to process
        #1; // Small delay to ensure output is stable
        if (intf.ack && intf.out == 16'd20)
            $display("Test 1 Passed: %d * %d = %d", a, b, intf.out);
        else
            $display("Test 1 Failed: %d * %d = %d (expected 20)", a, b, intf.out);

        // Disable enable signal
        #10;
        en  <= 0;
        @(posedge clk);
        #1;
        if (!intf.ack && intf.out == 16'd20) // out retains last value, ack should be 0
            $display("Test 2 Passed: en=0, ack=%b, out=%d (expected ack=0)", intf.ack, intf.out);
        else
            $display("Test 2 Failed: en=0, ack=%b, out=%d (expected ack=0)", intf.ack, intf.out);

        // Test case 3: 15 * 3 = 45
        #10;
        a   <= 8'd15;
        b   <= 8'd3;
        en  <= 1;
        @(posedge clk);
        #1;
        if (intf.ack && intf.out == 16'd45)
            $display("Test 3 Passed: %d * %d = %d", a, b, intf.out);
        else
            $display("Test 3 Failed: %d * %d = %d (expected 45)", a, b, intf.out);

        // Test case 4: 0 * 255 = 0 (edge case)
        #10;
        a   <= 8'd255;
        b   <= 8'd255;
        en  <= 1;
        @(posedge clk);
        #1;
        if (intf.ack && intf.out == 16'd0)
            $display("Test 4 Passed: %d * %d = %d", a, b, intf.out);
        else
            $display("Test 4 Failed: %d * %d = %d (expected 0)", a, b, intf.out);

        // Test case 5: Reset during operation
        #10;
        a   <= 8'd5;
        b   <= 8'd4;
        en  <= 1;
        #5;
        rst <= 1;
        @(posedge clk);
        #1;
        if (!intf.ack && intf.out == 16'd0)
            $display("Test 5 Passed: Reset test, ack=%b, out=%d", intf.ack, intf.out);
        else
            $display("Test 5 Failed: Reset test, ack=%b, out=%d (expected out=0, ack=0)", intf.ack, intf.out);

        // End simulation
        #20;
        $display("Simulation completed.");
        $finish;
    end


endmodule

