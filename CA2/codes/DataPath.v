module dataPath(

    input Row_en,
    input Bit_en,
    input element_en,
    input element_clr,   
    input Bit_clr,        
    input w_data_en,      
    input vec_a_en,
    input PE1_B_en,
    input PE2_B_en,
    input i_valid,
    input i_is_lsb,
    input i_is_msb,
    input [1:0] Addr_mux_sel,
    input clk,
    input rst,
    input [33:0] r_data,     
    

    output [6:0] address,   
    output [33:0] w_data,       
    output [2:0] Row_counter_out,
    output [2:0] element_cointer_out,
    output [3:0] Bit_counter_out
);


    wire [6:0] Addr_a, Addr_b, Addr_c;
    wire [33:0] PE1_out, PE2_out;
    wire [33:0] a0, a1, a2, a3, a4, a5, a6, a7;
    wire [63:0] PE1_B_out, PE2_B_out;
    wire [3:0] pe1_i_vec_a_bits, pe2_i_vec_a_bits;
    wire [33:0] w_data_from_adder;
    reg  [33:0] w_data_reg;        
    wire rst_n_inv;
    assign rst_n_inv = ~rst;

    counter #(3) Row_counter(rst, 1'b0, Row_en, clk, Row_counter_out);
    counter #(3) element_cointer(rst, element_clr, element_en, clk, element_cointer_out);
    counter #(4) Bit_counter(rst, Bit_clr, Bit_en, clk, Bit_counter_out);


    assign Addr_a = {4'b0 , element_cointer_out};
    assign Addr_b = 7'd8 + {Row_counter_out, element_cointer_out};
    assign Addr_c = 7'd72 + Row_counter_out;

    mux_3to1 #(7) Addr_mux(address, Addr_a, Addr_b, Addr_c, Addr_mux_sel);
    
    Vector_A_RegFile vector_a(clk, rst, vec_a_en, element_cointer_out, r_data, a0, a1, a2, a3, a4, a5, a6, a7);
    Bit_Slicer bit_slicer(a3,a2,a1,a0,a7,a6,a5,a4, Bit_counter_out, pe1_i_vec_a_bits, pe2_i_vec_a_bits);
    
    PE_B_Reg B1(clk, rst, PE1_B_en, element_cointer_out, r_data[15:0], PE1_B_out);
    
    PE_B_Reg B2(clk, rst, PE2_B_en, element_cointer_out, r_data[15:0], PE2_B_out);
    PE_stripes #(4,16,16) PE1(clk,rst_n_inv,i_valid,i_is_msb,i_is_lsb,pe1_i_vec_a_bits,PE1_B_out,34'd0,PE1_out); 
    PE_stripes #(4,16,16) PE2(clk,rst_n_inv,i_valid,i_is_msb,i_is_lsb,pe2_i_vec_a_bits,PE2_B_out,34'd0,PE2_out);
    adder #(34) PE_Adder(PE1_out, PE2_out, w_data_from_adder);


    always @(posedge clk or posedge rst) begin
        if (rst)
            w_data_reg <= 34'd0;
        else if (w_data_en)
            w_data_reg <= w_data_from_adder;
    end
    
    
    assign w_data = w_data_reg;

endmodule
