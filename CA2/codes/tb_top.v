`timescale 1ns / 1ps

module tb_top;

    reg clk;
    reg rst;
    reg start;
    wire done;

  
    top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done)
    );

  
    localparam CLK_PERIOD = 10;
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2);
        clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

  
    initial begin
      
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_top);
        $display("Simulation Started...");
        start = 1'b0;
        rst = 1'b1;
        $display("[%0t ns] Asserting Reset...", $time);
        #(CLK_PERIOD * 5);
        
        rst = 1'b0;
        $display("[%0t ns] De-asserting Reset.", $time);
        #(CLK_PERIOD * 2); 
        

        $display("[%0t ns] Sending Start Pulse...", $time);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        
        $display("[%0t ns] Waiting for 'done' signal...", $time);
        
        @(posedge done);
        
        $display("[%0t ns] 'done' signal received!", $time);
        $display("Matrix-Vector Multiplication complete.");
        
        #(CLK_PERIOD * 10);


        $display("[%0t ns] Simulation Finished.", $time);
        $finish;
    end

endmodule