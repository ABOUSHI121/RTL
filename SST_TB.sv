module SST_TB;

    
    logic        clk;
    logic        rst_n;
    logic        fire_valid;
    logic [1:0]  mode;
	
	
    logic        pulse_out;
    logic        busy;
    logic        fire_ready;
    logic        done;
    logic [8:0]  timer;	
    logic  [1:0] state_out;	 
	
	
	logic        pulse_out_ref;
    logic        busy_ref;
    logic        fire_ready_ref;
    logic        done_ref;
    logic [8:0]  timer_ref;	
    logic  [1:0] state_out_ref;

    single_shot_timer dut (
        .clk(clk),
        .rst_n(rst_n),
        .fire_valid(fire_valid),
        .mode(mode),
        .pulse_out(pulse_out),
        .busy(busy),
        .fire_ready(fire_ready),
        .done(done),
        .timer(timer), 
        .state_out(state_out)
    );	 
	
    single_shot_timer_ref ref_model (
        .clk(clk),
        .rst_n(rst_n),
        .fire_valid(fire_valid),
        .mode(mode),
        .pulse_out(pulse_out_ref),
        .busy(busy_ref),
        .fire_ready(fire_ready_ref),
        .done(done_ref),
        .timer(timer_ref) 
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    task automatic fire_and_wait(input [1:0] mode_sel);
        int cycles;
        begin
            mode <= mode_sel;
            fire_valid <= 1;
            @(posedge clk);   
            cycles = (32 << mode_sel);

            repeat(cycles/2) @(posedge clk);  
			fire_valid <= 0;				   
			repeat(cycles/2) @(posedge clk);  
        end
    endtask


    initial begin

        rst_n <= 0;
        fire_valid <= 1;
        mode <= 2'b00;

        #10;
        rst_n <= 1;
        @(posedge clk);


        $display("Testing Mode 00...");
        fire_and_wait(2'b00);

        $display("Testing Mode 01...");
        fire_and_wait(2'b01);

        $display("Testing Mode 10...");
        fire_and_wait(2'b10);

        $display("Testing Mode 11...");
        fire_and_wait(2'b11);

        $display("Testing Reset during count...");
        mode <= 2'b10;
        fire_valid <= 1;
        @(posedge clk);
        fire_valid <= 0;
        repeat(2) @(posedge clk);
        rst_n <= 0;
        repeat(2) @(posedge clk);
        rst_n <= 1;
        repeat(5) @(posedge clk);

        $display("Simulation completed!");
        $finish;
    end

    initial begin
        $monitor("Time=%0t rst_n=%b mode=%b fire_valid=%b state=%b timer=%0d pulse_out=%b busy=%b fire_ready=%b done=%b",
                 $time, rst_n, mode, fire_valid, dut.state, timer, pulse_out, busy, fire_ready, done);
    end

endmodule		 























