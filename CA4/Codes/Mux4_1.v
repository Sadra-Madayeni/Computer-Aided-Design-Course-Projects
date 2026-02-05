module mux_4to1 #(parameter n = 1) (
    input  [n-1:0] a,
    input  [n-1:0] b,
    input  [n-1:0] c,
    input  [n-1:0] d,
    input  [1:0]   s,
    output [n-1:0] f
);
    assign f = (s == 2'b00) ? a :
               (s == 2'b01) ? b :
               (s == 2'b10) ? c : d;
endmodule

