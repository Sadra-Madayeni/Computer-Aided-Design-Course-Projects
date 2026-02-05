module Memory (
    input wire clk,
    input wire rst,
    input wire        write_enable, 
    input wire [6:0]  address,      
    input wire [33:0] write_data,   

    output wire [33:0] read_data     
);


    reg [33:0] mem [0:127];

    always @(posedge clk) begin
        if (write_enable) begin
            mem[address] <= write_data;
        end
    end

   
    assign read_data = mem[address];

    initial begin
        $readmemh("input_memory.txt", mem);
    end

endmodule