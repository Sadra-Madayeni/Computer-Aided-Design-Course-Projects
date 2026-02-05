module rand_datapath(
    input clk,
    input rst,
    input load,
    input shift_en,
    input xor_en,
    input [5:0] data_in,
    output reg [5:0] data_out,
    output reg [1:0] result
);

reg [5:0] shift_reg;

wire xor_result = shift_reg[5] ^ shift_reg[3] ^ shift_reg[1];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        shift_reg <= 6'b0;
        data_out <= 6'b0;
        result <= 2'b00;
    end else begin
        if (load) begin
            shift_reg <= data_in;
            result <= 2'b00;
        end else if (xor_en) begin
            shift_reg <= {shift_reg[4:0], xor_result};
        end else if (shift_en) begin
            shift_reg <= {shift_reg[4:0], 1'b0};
        end
        
        data_out <= shift_reg;
        
        result <= shift_reg[5:4];
    end
end

endmodule
