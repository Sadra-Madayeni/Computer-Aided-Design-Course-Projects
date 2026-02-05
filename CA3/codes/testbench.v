`timescale 1ns/1ns

module tb_top;

    reg clk;
    reg rst;
    reg start; 
    reg [7:0] a0, b0, c0, d0;
    reg [5:0] data_in;
    reg [31:0] msg;
    wire Done;
    wire [31:0] digest;

    reg [31:0] test_vectors [0:63];     
    reg [31:0] expected_results [0:63];
    
    integer i;
    integer errors;

    TopModule uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a0(a0), .b0(b0), .c0(c0), .d0(d0),
        .msg(msg),
        .data_in(data_in),
        .Done(Done),
        .digest(digest)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $readmemh("testcase.txt", test_vectors);
        $readmemh("out_hw.txt", expected_results);

   
        a0 = 8'h01; b0 = 8'h89; c0 = 8'hFE; d0 = 8'h76;
        data_in = 6'b000000;
        errors = 0;

     
        for (i = 0; i < 64; i = i + 1) begin
            
            msg = test_vectors[i];   
            start = 0;
            rst = 1;
            #20;
            rst = 0;
            #10 start = 1;
            #10 start = 0; 
            wait(Done == 1);
            #10;
            
            #20;
        end

        $stop;
    end

endmodule