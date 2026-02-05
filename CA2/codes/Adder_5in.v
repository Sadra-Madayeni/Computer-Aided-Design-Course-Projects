module parametric_5_input_adder
#(
  parameter WIDTH = 8
)
(
  input wire [WIDTH-1:0] in_a, input wire [WIDTH-1:0] in_b,
  input wire [WIDTH-1:0] in_c, input wire [WIDTH-1:0] in_d,
  input wire [WIDTH-1:0] in_e,
  output wire [WIDTH+2:0] sum 
);
  assign sum = in_a + in_b + in_c + in_d + in_e;
endmodule