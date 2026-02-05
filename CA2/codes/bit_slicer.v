module Bit_Slicer (

    input wire [33:0] a_0_data,
    input wire [33:0] a_1_data,
    input wire [33:0] a_2_data,
    input wire [33:0] a_3_data,
    input wire [33:0] a_4_data,
    input wire [33:0] a_5_data,
    input wire [33:0] a_6_data,
    input wire [33:0] a_7_data,
    input wire [3:0]  bit_counter,

    output wire [3:0] pe1_i_vec_a_bits,
    output wire [3:0] pe2_i_vec_a_bits
);

    wire [3:0] bit_index;
    assign bit_index = 15 - bit_counter;
    assign pe1_i_vec_a_bits = { a_3_data[bit_index], 
                                a_2_data[bit_index], 
                                a_1_data[bit_index], 
                                a_0_data[bit_index] };
                                

    assign pe2_i_vec_a_bits = { a_7_data[bit_index], 
                                a_6_data[bit_index], 
                                a_5_data[bit_index], 
                                a_4_data[bit_index] };

endmodule