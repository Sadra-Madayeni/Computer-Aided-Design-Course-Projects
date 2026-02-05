module B_Element_Reg (
    input wire clk,
    input wire rst,
    input wire load_en,  
    input wire [15:0] d,  
    output reg [15:0] q    
);


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 16'b0;
        end else if (load_en) begin
            q <= d;
        end
        
    end

endmodule