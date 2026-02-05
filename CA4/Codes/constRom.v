module const_rom (
    input [5:0] address,
    output [7:0] data
);
    reg [7:0] rom [0:63]; 
    initial begin
        $readmemh("k.mem", rom);
    end
    assign data = rom[address]; 
endmodule