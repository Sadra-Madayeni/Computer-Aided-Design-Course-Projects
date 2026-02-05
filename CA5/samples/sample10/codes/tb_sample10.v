`timescale 1ns/1ns

module tb;
  reg clk;
  reg rst;
  reg start;
  reg [31:0] i1, i2, i3, i4, i5, i6;
  wire [31:0] result;
  wire done;

  top_module uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .i1(i1), .i2(i2), .i3(i3), .i4(i4),
    .i5(i5), .i6(i6),
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
    i1 = 32'd2;
    i2 = 32'd3;
    i3 = 32'd4;
    i4 = 32'd2;
    i5 = 32'd3;
    i6 = 32'd1;
    
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