`timescale 1ns/1ps

module alu(
	input 	logic 		clk,
	input 	logic [7:0] BussA, BussB,
	input 	logic [2:0] OPCODE,
	output 	logic 		Zero,
	output 	logic [7:0] OUT
	);		
	
	always_comb begin
		
    	Zero = (BussA == BussB);
	
	end 	 
	
	always_ff @(negedge clk) begin 
		
		
		unique case(OPCODE)
			
			AND:		OUT <= BussA &  BussB;
			ADD:		OUT <= BussA +  BussB;	
			SUB:		OUT <= BussA -  BussB;
			SLR:		OUT <= BussA >> BussB; 
			JAL:		OUT <= BussA +  BussB;
			default:	OUT <= 8'b0; 
			
		endcase
		
	end

	
endmodule 
