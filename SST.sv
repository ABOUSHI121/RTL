`timescale 1ns/1ps

//==========================================
// SST module
//==========================================

module single_shot_timer(
	
	input 	logic			clk			, rst_n	, 
	input 	logic			fire_valid	,
	input 	logic	[1:0] 	mode		,
	
	
	output 	logic			pulse_out	, busy	,  
	output 	logic			fire_ready	, done	,
	output 	logic 	[8:0]	timer		,
	output 	logic 	[1:0]	state_out
	
	);					
	
	logic [1:0]	state	;
	
	localparam 	IDLE = 2'b00, COUNT = 2'b01, 
				DONE = 2'b10, WR	= 2'b11;
	
	
	always_ff @(posedge clk) begin
	   	state_out	<= state;
		if (!rst_n) begin
			
			timer		<= 0		;  			
			pulse_out   <= 0		;
			busy 		<= 0		;
			fire_ready	<= 1		;
			done		<= 0		;
									
			state		<= IDLE		; 	 
			
		end	
		
		else
		
			unique case(state)
				
				IDLE	: begin
					
					timer		<= 0		;
					busy 		<= 0		;
					done		<= 0		;
					if (fire_valid)	begin
						
						state		<= COUNT			;
						timer 		<= 32	  << mode	;  
						
						fire_ready	<= 0				;
						pulse_out	<= 1				;	
						busy		<= 1				;
						done		<= 0				; 
						
					end	

				end 
				
				
				WR		: begin	
					
	
				end
					
				
				
				COUNT	: begin 
					
					timer 			<= timer - 1; 
					
					if (timer-2 == 0)
						state		<= DONE		;
						
					
				end
				
				
				
				DONE	: begin 
					
					state		<= IDLE		;
					pulse_out	<= 0		;	
					busy		<= 0		;
					done		<= 1		; 
					fire_ready	<= 1		;  
					timer 		<= 0		;
				 	
				end
				
				
			endcase	
		
		
		
	end

	

	
endmodule






module single_shot_timer_ref (
  input  logic        clk,
  input  logic        rst_n,

  input  logic        fire_valid,
  output logic        fire_ready,

  input  logic [1:0]  mode,

  output logic        pulse_out,
  output logic        busy,
  output logic        done,
  output logic [8:0]  timer
);

  int unsigned count_left;

  // Mode-to-cycle mapping
  function automatic int unsigned mode_to_cycles(logic [1:0] m);
    case (m)
      2'b00: return 32;
      2'b01: return 64;
      2'b10: return 128;
      2'b11: return 256;
    endcase
  endfunction


  initial begin
    count_left = 0;
    fire_ready = 1'b1;
    pulse_out  = 1'b0;
    busy       = 1'b0;
    done       = 1'b0;
    timer      = '0;

    forever begin
      @(posedge clk);

      if (!rst_n) begin
        count_left = 0;
        fire_ready = 1'b1;
        pulse_out  = 1'b0;
        busy       = 1'b0;
        done       = 1'b0;
        timer      = '0;
      end else begin
        done = 1'b0;

        // Ready only when idle
        fire_ready = (count_left == 0);

        // Fire new timer
        if (fire_valid && fire_ready) begin
          count_left 	= mode_to_cycles(mode);
		  fire_ready 	= 0		;
        end
        // Decrement timer
        else if (count_left > 0) begin
          count_left -= 1;
          if (count_left == 0) begin
            done = 1'b1;
          end
        end

        // Outputs
        if (count_left > 0) begin
          pulse_out = 1'b1;
          busy      = 1'b1;
          timer     = count_left[8:0];
        end else begin
          pulse_out = 1'b0;
          busy      = 1'b0;
          timer     = '0;
		  fire_ready = 1'b1;
        end
      end
    end
  end

endmodule


   