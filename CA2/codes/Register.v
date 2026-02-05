module register #(parameter n = 32)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [n-1:0] d,
    output reg [n-1:0] q
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= {n{1'b0}};
        else if (en)
            q <= d;
    end

endmodule
