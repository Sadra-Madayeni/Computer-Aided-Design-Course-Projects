`timescale 1ns / 1ns

module tb_TopModule;


    reg clk;
    reg rst;
    reg start;
    reg [31:0] a0, b0, c0, d0;
    reg [127:0] msg;
    reg [5:0] data_in;

    wire Done;
    wire [127:0] digest;

    TopModule dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a0(a0),
        .b0(b0),
        .c0(c0),
        .d0(d0),
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
        rst = 1;
        start = 0;
        data_in = 6'b000111;

        msg = 128'h41a801a8e81df62b14a661b85c97bf45;

        a0 = 32'h67452301;
        b0 = 32'hefcdab89;
        c0 = 32'h98badcfe;
        d0 = 32'h10325476;

        #20 rst = 0;

        #30 start = 1;
        #10 start = 0;

        $display("Starting simulation at time %0t", $time);
        $monitor("Time=%0t: Done=%b, digest=%h", $time, Done, digest);

        wait(Done == 1'b1);
        $display("Operation completed at time %0t", $time);
        $display("Final digest: %h", digest);
        
        #1000;
        $display("Simulation finished at time %0t", $time);
        $stop;
    end

    initial begin
        #5;
        forever begin
            #10;
            if (Done) begin
                $display("=== OPERATION COMPLETED ===");
                $display("Digest: %h", digest);
            end
        end
    end

endmodule
