module top_rand(
    input clk,
    input rst,
    input start,
    input [5:0] data_in,
    output [5:0] data_out,
    output [1:0] result,
    output done
);
    
    wire load, shift_en, xor_en;
    wire [2:0] shift_count_wire; 

    rand_controller ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .shift_count(shift_count_wire),
        .load(load),
        .shift_en(shift_en),
        .xor_en(xor_en),
        .done(done)
    );
    

    rand_dp dp (                   
        .clk(clk),
        .rst(rst),
        .load(load),
        .shift_en(shift_en),
        .xor_en(xor_en),
        .data_in(data_in),
        .data_out(data_out),
        .result(result),
        .shift_count_out(shift_count_wire)
    );
endmodule