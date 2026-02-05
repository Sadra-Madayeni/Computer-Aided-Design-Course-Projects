module mux_3to1 #(parameter n=1) (
    output wire [n-1:0] f,
    input wire [n-1:0] a, 
    input wire [n-1:0] b, 
    input wire [n-1:0] c, 
    input wire [1:0]   s  
);

    
    assign f = (s == 2'b00) ? a :
               (s == 2'b01) ? b :
               (s == 2'b10) ? c :
               'hz; 

endmodule