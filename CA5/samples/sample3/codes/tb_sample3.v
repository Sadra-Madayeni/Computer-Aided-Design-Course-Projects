`timescale 1ns/1ns

module tb;
  reg clk;
  reg rst;
  reg start;
  reg [31:0] i1, i2;
  wire [31:0] result;
  wire done;

  top_module uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .i1(i1), .i2(i2),
    .result(result),
    .done(done)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 1;
    start = 0;
    i1 = 32'd10;
    i2 = 32'd5;
    
    #15;
    rst = 0;
    
    #10;
    start = 1;
    #10;
    start = 0;

    wait(done);
    #10;
    
    $stop;
  end

endmodule