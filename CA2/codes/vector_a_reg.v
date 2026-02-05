module Vector_A_RegFile (
    input wire clk,
    input wire rst,
    input wire w_en,              
    input wire [2:0] w_addr,       
    input wire [33:0] w_data,     

    
    output wire [33:0] a_0_data,
    output wire [33:0] a_1_data,
    output wire [33:0] a_2_data,
    output wire [33:0] a_3_data,
    output wire [33:0] a_4_data,
    output wire [33:0] a_5_data,
    output wire [33:0] a_6_data,
    output wire [33:0] a_7_data
);


    reg [33:0] mem [0:7];   
    integer i;

   
    always @(posedge clk or posedge rst) begin
        if (rst) begin  
            for (i = 0; i < 8; i = i + 1) begin 
                mem[i] <= 34'b0;
            end
        end else if (w_en) begin
          
            mem[w_addr] <= w_data;
        end
    end

    assign a_0_data = mem[0];
    assign a_1_data = mem[1];
    assign a_2_data = mem[2];
    assign a_3_data = mem[3];
    assign a_4_data = mem[4];
    assign a_5_data = mem[5];
    assign a_6_data = mem[6];
    assign a_7_data = mem[7];

endmodule