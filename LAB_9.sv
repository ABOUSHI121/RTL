module dff (
    input logic clk,
    input logic rst,
    input logic D,
    output logic Q,
    output logic QN
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            Q <= 1'b0;
        else
            Q <= D;
    end
    assign QN = ~Q;
endmodule

module tb_dff;
    logic clk;
    logic rst;
    logic D;
    logic Q;
    logic QN;

    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end

    // Clocking block definition
    clocking cb @(posedge clk);
        default input #1ns output #3ns;
        input Q, QN;
        output D, rst;
    endclocking


    dff uut (
        .clk(clk),
        .rst(rst),
        .D(D),
        .Q(Q),
        .QN(QN)
    );


    initial begin
    
        @(cb);
        cb.rst <= 1'b1;
        cb.D <= 1'b0;

    
        #10ns;
        @(cb);
        cb.rst <= 1'b0;

 
        repeat (5) begin
            @(cb);
            cb.D <= $random;
        end

   
        repeat (3) begin
            @(cb);
            cb.D <= 1'b1;
            @(cb);
            cb.D <= 1'b0;
        end

     
        @(cb);
        cb.rst <= 1'b1;
        #10ns;
        @(cb);
        cb.rst <= 1'b0;

 
        repeat (5) begin
            @(cb);
            cb.D <= $random;
        end

        #20ns;
        $finish;
    end
 
endmodule
