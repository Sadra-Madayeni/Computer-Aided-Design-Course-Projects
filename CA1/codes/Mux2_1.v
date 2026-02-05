module mux_2to1 #(parameter n=1) (f, s, a, b);
    input [n-1:0] a;
    input [n-1:0] b;
    input s;
    output [n-1:0] f;
    assign f = s ? b : a;
endmodule
