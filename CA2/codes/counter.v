module counter #(parameter n = 6) (
    input wire reset,
    input wire clear,
    input wire enable, 
    input wire clock, 
    output reg [n-1:0] p_out,
    output wire cout
);
    assign cout = &p_out;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            p_out <= {(n){1'b0}};
        end else if (clear) begin 
            p_out <= {(n){1'b0}};
        end else if (enable) begin
            p_out <= p_out + 1;
        end
    end
endmodule
