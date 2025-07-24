`timescale 1ns/1ps
  typedef enum logic [2:0] {
    AND 	= 3'b000,
    ADD 	= 3'b001,
    SUB 	= 3'b010,
    SLR 	= 3'b011,
    BEQ 	= 3'b100,
    JAL 	= 3'b101,
    LW  	= 3'b110,
    SW  	= 3'b111
  } opcode_t;

  typedef enum logic [2:0] {
    IDLE    	= 3'b000,
    FETCH   	= 3'b001,
    DECODE  	= 3'b010,
    EXECUTE 	= 3'b011,
    ALU     	= 3'b100,
    LOAD   		= 3'b101,
    STORE   	= 3'b110,
    WRITEBACK 	= 3'b111
  } stage_t;

module control (
  input logic 	clk, rst_,
  input 		opcode_t opcode,
  input logic 	zero,
  output logic 	SIG_FET, SIG_DEC, SIG_IDL,
  				SIG_EXC, SIG_ALU, SIG_LDM, 
  				SIG_STM, SIG_WBK
);
	stage_t current_state, next_state;

  always_ff @(posedge clk or negedge rst_) begin
    if (!rst_)
      current_state <= IDLE;
    else
      current_state <= next_state;
  end

  // Combinational logic for next state and outputs
  always_comb begin
    // Default outputs
    {SIG_FET, SIG_DEC, SIG_IDL, SIG_EXC, SIG_ALU, SIG_LDM, SIG_STM, SIG_WBK} = 8'b0;
    next_state = current_state;

    unique case (current_state)
		
      IDLE: begin
        SIG_IDL 	= 1'b1;
        next_state 	= FETCH;
      end  
	  
      FETCH: begin
        SIG_FET 	= 1'b1;
        next_state 	= DECODE;
      end
	  
      DECODE: begin
        SIG_DEC 	= 1'b1;
        unique case (opcode)
          AND, ADD, SUB, SLR: 	next_state = ALU;
          BEQ: 					next_state = (zero) ? EXECUTE : FETCH;
          JAL: 					next_state = EXECUTE;
          LW:  					next_state = LOAD;
          SW:  					next_state = STORE;
          default: 				next_state = IDLE;
        endcase
      end
	  
      ALU: begin
        SIG_ALU 	= 1'b1;
        next_state 	= WRITEBACK;
      end
	  
      EXECUTE: begin
        SIG_EXC 	= 1'b1;
        next_state 	= FETCH;
      end 
	  
      LOAD: begin
        SIG_LDM 	= 1'b1;
        next_state 	= WRITEBACK;
      end  
	  
      STORE: begin
        SIG_STM 	= 1'b1;
        next_state 	= FETCH;
      end 
	  
      WRITEBACK: begin
        SIG_WBK 	= 1'b1;
        next_state 	= FETCH;
      end 
	  
      default: begin
        next_state 	= IDLE;
        SIG_IDL 	= 1'b1;
      end 
	  
    endcase
  end
endmodule	
