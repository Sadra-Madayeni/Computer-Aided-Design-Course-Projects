module mux_2to1 
#(
  parameter WIDTH=1
) 
(
  f, s, a, b
);
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  input s;
  output [WIDTH-1:0] f;
  
  assign f = s ? b : a;
endmodule