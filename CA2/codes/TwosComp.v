module parametric_twos_comp_classic 
#( 
  parameter WIDTH = 8 
)
(
  input  wire [WIDTH-1:0] in_a,    
  output wire [WIDTH-1:0] out_neg  
);
  wire [WIDTH-1:0] ones_complement;
  assign ones_complement = ~in_a;
  assign out_neg = ones_complement + 1'b1;
endmodule