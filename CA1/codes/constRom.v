module const_rom (
    input [5:0] address,
    output reg [31:0] data
);
    reg [31:0] rom [0:63];
    
    initial begin
        $readmemh("constant.mem", rom);
    end
    
    always @(*) begin
        data = rom[address];
    end
endmodule
