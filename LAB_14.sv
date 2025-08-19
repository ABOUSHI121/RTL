interface mem_if (
    input logic clk
);
    logic read;
    logic write;
    logic [4:0] addr;
    logic [7:0] data_in;
    logic [7:0] data_out;


    task automatic write_mem;
        input [4:0] address;
        input [7:0] data;
        input bit debug;
        begin
            @(negedge clk);
            addr = address;
            data_in = data;
            read = 0;
            write = 1;
            @(posedge clk);
            #1;
            write = 0;
            if (debug)
                $display("Write: addr=%0h, data=%0h at time=%0t", address, data, $time);
        end
    endtask


    task automatic read_mem;
        input [4:0] address;
        output [7:0] data;
        input bit debug;
        begin
            @(negedge clk);
            addr = address;
            read = 1;
            write = 0;
            @(posedge clk);
            #1;
            data = data_out;
            read = 0;
            if (debug)
                $display("Read: addr=%0h, data=%0h at time=%0t", address, data, $time);
        end
    endtask


    modport memory (
        input clk, read, write, addr, data_in,
        output data_out
    );

    modport test (
        input clk, data_out,
        output read, write, addr, data_in,
        import write_mem, read_mem 
    );

endinterface


module mem (
    mem_if.memory mem_if_inst
);
    timeunit 1ns; timeprecision 1ns;

    logic [7:0] memory[0:31];

    always @(posedge mem_if_inst.clk) 
        if (mem_if_inst.write && !mem_if_inst.read) 
            #1 memory[mem_if_inst.addr] <= mem_if_inst.data_in;

    always_ff @(posedge mem_if_inst.clk iff ((mem_if_inst.read == '1) && (mem_if_inst.write == '0))) 
        mem_if_inst.data_out <= memory[mem_if_inst.addr];

endmodule


module mem_test (
    mem_if.test mem_if_inst
);
    timeunit 1ns; timeprecision 1ns;

    bit debug = 1;
    logic [7:0] rdata;
  

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
        

        for (int i = 0; i < 32; i++) begin
            mem_if_inst.write_mem(i, 8'h00, debug);
        end
        
        for (int i = 0; i < 32; i++) begin
            mem_if_inst.read_mem(i, rdata, debug);
            if (rdata !== 8'h00) begin
                $display("Error: addr=%0h, expected=00, got=%0h", i, rdata);
                error_status++;
            end
        end
        
        printstatus(error_status);

        $display("Data = Address Test");
        error_status = 0;
        

        for (int i = 0; i < 32; i++) begin
            mem_if_inst.write_mem(i, i, debug);
        end
        
        for (int i = 0; i < 32; i++) begin
            mem_if_inst.read_mem(i, rdata, debug);
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

    bit clk;
    

    mem_if mem_if_inst (.clk(clk));

    mem_test test (
        .mem_if_inst(mem_if_inst.test)
    );

    mem memory (
        .mem_if_inst(mem_if_inst.memory)
    );

    always #5 clk = ~clk;

endmodule
