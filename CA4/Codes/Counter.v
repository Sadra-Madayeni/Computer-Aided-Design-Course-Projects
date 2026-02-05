module counter #(parameter n = 6) (reset, enable, clock, p_out, cout);
    input enable, clock, reset;
    output reg [n-1:0] p_out;
    output cout;
    
    assign cout = &p_out;
    always @(posedge clock) begin
        if (reset) begin
            p_out <= {(n){1'b0}};
        end
        else if (enable) begin
            p_out <= p_out + 1'b1;
        end
    end
endmodule