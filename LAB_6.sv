 
module mem (
    input              clk,
    input              read,
    input              write,
    input  logic [4:0] addr,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);
  timeunit 1ns; timeprecision 1ns;

  logic [7:0] memory[0:31];

  always @(posedge clk) if (write && !read) #1 memory[addr] <= data_in;

  always_ff @(posedge clk iff ((read == '1) && (write == '0))) data_out <= memory[addr];

endmodule




module mem_test (
    input logic clk,
    output logic read,
    output logic write,
    output logic [4:0] addr,
    output logic [7:0] data_in,
    input wire [7:0] data_out
);
  timeunit 1ns; timeprecision 1ns;

  bit debug = 1;
  logic [7:0] rdata;
  
  // Write memory task
  task write_mem;
    input [4:0] address;
    input [7:0] data;
    input bit debug = 0;
    begin
      @(negedge clk); // Drive signals on negative edge to avoid race
      addr = address;
      data_in = data;
      read = 0;
      write = 1;
      @(posedge clk); // Wait for positive edge for write
      #1; 
      write = 0; 
      if (debug)
        $display("Write: addr=%0h, data=%0h at time=%0t", address, data, $time);
    end
  endtask

  // Read memory task
  task read_mem;
    input [4:0] address;
    output [7:0] data;
    input bit debug = 0;
    begin
      @(negedge clk); // Drive signals on negative edge
      addr = address;
      read = 1;
      write = 0;
      @(posedge clk); // Wait for positive edge for read
      #1; // Wait for data_out to update
      data = data_out;
      read = 0; // Clear read signal
      if (debug)
        $display("Read: addr=%0h, data=%0h at time=%0t", address, data, $time);
    end
  endtask

  // Print status function
  function void printstatus(input int status);
    if (status == 0)
      $display("Test PASSED: No errors detected");
    else
      $display("Test FAILED: %0d errors detected", status);
  endfunction

  initial begin
    $timeformat(-9, 0, " ns", 9);
    #40000ns $display("MEMORY TEST TIMEOUT");
    $finish;
  end

  initial begin : memtest
    int error_status;

    $display("Clear Memory Test");
    error_status = 0;
    
    // Clear Memory Test
    for (int i = 0; i < 32; i++) begin
      write_mem(i, 8'h00, debug); // Write zero to every address
    end
    
    for (int i = 0; i < 32; i++) begin
      read_mem(i, rdata, debug); // Read from every address
      if (rdata !== 8'h00) begin
        $display("Error: addr=%0h, expected=00, got=%0h", i, rdata);
        error_status++;
      end
    end
    
    printstatus(error_status);

    $display("Data = Address Test");
    error_status = 0;
    
    // Data = Address Test
    for (int i = 0; i < 32; i++) begin
      write_mem(i, i, debug); // Write address as data
    end
    
    for (int i = 0; i < 32; i++) begin
      read_mem(i, rdata, debug); // Read from every address
      if (rdata !== i) begin
        $display("Error: addr=%0h, expected=%0h, got=%0h", i, i, rdata);
        error_status++;
      end
    end
    
    printstatus(error_status);
    
    $finish;
  end
endmodule










module top;
  timeunit 1ns; timeprecision 1ns;

  bit        clk;
  wire       read;
  wire       write;
  wire [4:0] addr;

  wire [7:0] data_out;  
  wire [7:0] data_in;  

  mem_test test (.*);

  mem memory (
      .clk,
      .read,
      .write,
      .addr,
      .data_in,
      .data_out
  );

  always #5 clk = ~clk;
endmodule


