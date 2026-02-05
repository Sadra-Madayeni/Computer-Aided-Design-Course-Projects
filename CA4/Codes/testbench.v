`timescale 1ns / 1ns

module tb_top;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] a0, b0, c0, d0;
    
    reg [31:0] msg;

    wire Done;
    wire [31:0] digest;

    integer file_in, file_out, scan_res;

    TopModule dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a0(a0),
        .b0(b0),
        .c0(c0),
        .d0(d0),
        .msg(msg),
        .Done(Done),
        .digest(digest)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        a0 = 8'h01;
        b0 = 8'h89;
        c0 = 8'hFE;
        d0 = 8'h76;

        rst = 1;
        start = 0;
        
        
        file_in = $fopen("testcase3.txt", "r");
        file_out = $fopen("golden_out_hw3.txt", "w");

        if (file_in == 0) begin
            $display("Error: Could not open testcase3.txt");
            $stop;
        end

        #20 rst = 0;

    
        while (!$feof(file_in)) begin
            
            scan_res = $fscanf(file_in, "%h\n", msg);
            
            if (scan_res == 1) begin
            
                #10 start = 1;
                #10 start = 0;

                
                wait(Done == 1);
                #5;

                $fwrite(file_out, "%h\n", digest);
                $display("Input: %h -> Digest: %h", msg, digest);

                #20;
            end
        end

        $fclose(file_in);
        $fclose(file_out);
        $stop;
    end

endmodule