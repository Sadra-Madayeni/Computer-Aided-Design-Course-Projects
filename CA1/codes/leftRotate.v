module left_rotate (
    input [31:0] data_in,
    input [5:0] step_index,   
    output [31:0] data_out
);

    reg [4:0] step_value;

    always @(*) begin
        case (step_index[1:0]) 
            2'b00: step_value = (step_index < 16) ? 5'd7 : 
                               (step_index < 32) ? 5'd5 : 
                               (step_index < 48) ? 5'd4 : 5'd6;
            2'b01: step_value = (step_index < 16) ? 5'd12 : 
                               (step_index < 32) ? 5'd9 : 
                               (step_index < 48) ? 5'd11 : 5'd10;
            2'b10: step_value = (step_index < 16) ? 5'd17 : 
                               (step_index < 32) ? 5'd14 : 
                               (step_index < 48) ? 5'd16 : 5'd15;
            2'b11: step_value = (step_index < 16) ? 5'd22 : 
                               (step_index < 32) ? 5'd20 : 
                               (step_index < 48) ? 5'd23 : 5'd21;
        endcase
    end

    assign data_out = (data_in << step_value) | 
                     (data_in >> (32 - step_value));

endmodule
