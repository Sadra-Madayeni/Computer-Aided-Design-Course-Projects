module rom(input [5:0] addr, output [7:0] data);
    reg [7:0] mem [0:63];
    initial $readmemh("k.mem", mem);
    assign data = mem[addr];
endmodule