


module driver(
    output logic       rst_n, 
    output logic       fire_valid,
    output logic [1:0] mode,
    input  logic       clk       
);	

    task automatic fire_and_wait(input [1:0] mode_sel);
        int cycles;
        begin
            mode       <= mode_sel;
            fire_valid <= 1;
            @(posedge clk);   

            cycles = (2 << mode_sel);

            repeat(cycles/2) @(posedge clk);  
            fire_valid <= 0;				   
            repeat(cycles/2) @(posedge clk);  
        end
    endtask

endmodule




module monitor (
  input  logic clk,
  input  logic rst_n,

  // DUT 
  input  logic dut_pulse_out,
  input  logic dut_busy,
  input  logic dut_fire_ready,
  input  logic dut_done,
  input  logic [8:0] dut_timer,

  // REF 
  input  logic ref_pulse_out,
  input  logic ref_busy,
  input  logic ref_fire_ready,
  input  logic ref_done,
  input  logic [8:0] ref_timer
);


  always @(posedge clk) begin
    if (rst_n) begin
      top_tb.checker_i.compare(
        dut_pulse_out, dut_busy, dut_fire_ready, dut_done, dut_timer,
        ref_pulse_out, ref_busy, ref_fire_ready, ref_done, ref_timer
      );
    end
  end

endmodule







module checkers();

  task compare(
    input logic dut_pulse_out,
    input logic dut_busy,
    input logic dut_fire_ready,
    input logic dut_done,
    input logic [8:0] dut_timer,

    input logic ref_pulse_out,
    input logic ref_busy,
    input logic ref_fire_ready,
    input logic ref_done,
    input logic [8:0] ref_timer
  );
    begin
      if ((dut_pulse_out  !== ref_pulse_out)  ||
          (dut_busy       !== ref_busy)       ||
          (dut_done       !== ref_done)       ||
          (dut_timer      !== ref_timer)) begin
        $display("[%0t] ? MISMATCH", $time);
        $display("DUT: pulse=%0b busy=%0b ready=%0b done=%0b timer=%0d",
                  dut_pulse_out, dut_busy, dut_fire_ready, dut_done, dut_timer);
        $display("REF: pulse=%0b busy=%0b ready=%0b done=%0b timer=%0d",
                  ref_pulse_out, ref_busy, ref_fire_ready, ref_done, ref_timer);
        $display("CHECK FAILED");	
		$finish;
      end
      else begin
        $display("[%0t] MOMTAZ", $time);
      end
    end
  endtask

endmodule	 













module top_tb;


  logic clk, rst_n;
  logic fire_valid;
  logic [1:0] mode;

  // DUT 
  logic dut_pulse_out, dut_busy, dut_fire_ready, dut_done;
  logic [8:0] dut_timer;
  logic [1:0] dut_state; 

  // REF 
  logic ref_pulse_out, ref_busy, ref_fire_ready, ref_done;
  logic [8:0] ref_timer;


  initial begin
    clk = 0;
    forever #5 clk = ~clk; 
  end


  initial begin
    rst_n <= 0;
    #20 rst_n <= 1;
  end


  initial begin
    fire_valid <= 0;
    mode <= 0;
    @(posedge rst_n);

    repeat (1000) begin
      @(posedge clk);
      fire_valid <= 1;
      mode <= $urandom_range(0,3);
      @(posedge clk);
      fire_valid <= 0;
      wait (dut_fire_ready && ref_fire_ready);
    end

    #100;
    $finish;
  end

  // -------------------------
  // DUT instance
  // -------------------------
  single_shot_timer dut (
    .clk(clk), .rst_n(rst_n),
    .fire_valid(fire_valid),
    .mode(mode),
    .pulse_out(dut_pulse_out),
    .busy(dut_busy),
    .fire_ready(dut_fire_ready),
    .done(dut_done),
    .timer(dut_timer),
    .state_out(dut_state)
  );

  // -------------------------
  // REF instance
  // -------------------------
  single_shot_timer_ref ref_model (
    .clk(clk), .rst_n(rst_n),
    .fire_valid(fire_valid),
    .fire_ready(ref_fire_ready),
    .mode(mode),
    .pulse_out(ref_pulse_out),
    .busy(ref_busy),
    .done(ref_done),
    .timer(ref_timer)
  );

  // -------------------------
  // Checker & Monitor
  // -------------------------
  checkers checker_i();

  monitor mon (
    .clk(clk), .rst_n(rst_n),
    .dut_pulse_out(dut_pulse_out), .dut_busy(dut_busy),
    .dut_fire_ready(dut_fire_ready), .dut_done(dut_done),
    .dut_timer(dut_timer),
    .ref_pulse_out(ref_pulse_out), .ref_busy(ref_busy),
    .ref_fire_ready(ref_fire_ready), .ref_done(ref_done),
    .ref_timer(ref_timer)
  );

endmodule