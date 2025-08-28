
module SST_TEST;

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

  // -------------------------
  // Clock Gen
  // -------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk; 
  end

  // -------------------------
  // Reset Gen
  // -------------------------
  initial begin
    rst_n <= 0;
    repeat (3) @(posedge clk);
    rst_n <= 1;
  end

  // -------------------------
  // Stimulus
  // -------------------------
  initial begin
    fire_valid <= 0;
    mode <= 0;

    // Wait until reset is done
    @(posedge rst_n);

    // Run multiple randomized test sequences
    repeat (200) begin
      @(posedge clk);

      // Random chance to assert fire_valid (not always when ready!)
      if ($urandom_range(0, 100) < 30) begin
        fire_valid <= 1'b1;
        mode <= $urandom_range(0,3);
      end else begin
        fire_valid <= 1'b0;
      end

      // Occasionally insert mid-run reset
      if ($urandom_range(0,200) == 0) begin
        $display("[%0t] Injecting random reset",$time);
        rst_n <= 0;
        repeat (2) @(posedge clk);
        rst_n <= 1;
      end
    end

    // Drain
    repeat (20) @(posedge clk);
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
  // Checker
  // -------------------------
  always @(posedge clk) begin
    if (rst_n) begin
      if (dut_pulse_out   !== ref_pulse_out  ) $error("[%0t] Mismatch: pulse_out DUT=%0b REF=%0b", $time, dut_pulse_out, ref_pulse_out);
      if (dut_busy        !== ref_busy       ) $error("[%0t] Mismatch: busy DUT=%0b REF=%0b", $time, dut_busy, ref_busy);
      if (dut_fire_ready  !== ref_fire_ready ) $error("[%0t] Mismatch: fire_ready DUT=%0b REF=%0b", $time, dut_fire_ready, ref_fire_ready);
      if (dut_done        !== ref_done       ) $error("[%0t] Mismatch: done DUT=%0b REF=%0b", $time, dut_done, ref_done);
      if (dut_timer       !== ref_timer      ) $error("[%0t] Mismatch: timer DUT=%0d REF=%0d", $time, dut_timer, ref_timer);
    end
  end

endmodule



