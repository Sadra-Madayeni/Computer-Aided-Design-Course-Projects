module PE_B_Reg (
    input wire clk,
    input wire rst,
    input wire load_en,
    input wire [2:0] element_cointer_out, 
    input wire [15:0] d_in,
    output reg [63:0] q_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q_out <= 64'b0;
        end else if (load_en) begin
            
            if (element_cointer_out == 3'd0 || element_cointer_out == 3'd4) begin
                q_out <= {48'b0, d_in}; 
            end else begin
                q_out <= {q_out[47:0], d_in}; 
            end
        end
    end

endmodule