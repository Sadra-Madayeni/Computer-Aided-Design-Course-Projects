module top (
    input wire clk,
    input wire rst,
    input wire start,
    output wire done  
);

   
    wire Row_en;
    wire Bit_en;
    wire element_en;
    wire element_clr;   
    wire Bit_clr;      
    wire w_data_en;     
    wire vec_a_en;
    wire PE1_B_en;
    wire PE2_B_en;
    wire i_valid;
    wire i_is_lsb;
    wire i_is_msb;
    wire [1:0] Addr_mux_sel;
    wire [2:0] Row_counter_out;
    wire [2:0] element_cointer_out;
    wire [3:0] Bit_counter_out;
    wire [6:0]  mem_address;     
    wire [33:0] mem_write_data;   
    wire [33:0] mem_read_data;   
    wire        mem_write_enable; 

    
    
    Memory mem_unit (
        .clk(clk),
        .rst(rst),
        .write_enable(mem_write_enable), 
        .address(mem_address),          
        .write_data(mem_write_data),     
        .read_data(mem_read_data)     
    );

    
   
    Controller controller_unit (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .Row_counter_out(Row_counter_out),
        .element_cointer_out(element_cointer_out),
        .Bit_counter_out(Bit_counter_out),
        .Row_en(Row_en),
        .Bit_en(Bit_en),
        .element_en(element_en),
        .element_clr(element_clr),     
        .Bit_clr(Bit_clr),         
        .w_data_en(w_data_en),       
        .vec_a_en(vec_a_en),
        .PE1_B_en(PE1_B_en),
        .PE2_B_en(PE2_B_en),
        .i_valid(i_valid),
        .i_is_lsb(i_is_lsb),
        .i_is_msb(i_is_msb),
        .Addr_mux_sel(Addr_mux_sel),
        .write(mem_write_enable)
    );

    
    
    dataPath datapath_unit (
        .Row_en(Row_en),
        .Bit_en(Bit_en),
        .element_en(element_en),
        .element_clr(element_clr),     
        .Bit_clr(Bit_clr),         
        .w_data_en(w_data_en),       
        .vec_a_en(vec_a_en),
        .PE1_B_en(PE1_B_en),
        .PE2_B_en(PE2_B_en),
        .i_valid(i_valid),
        .i_is_lsb(i_is_lsb),
        .i_is_msb(i_is_msb),
        .Addr_mux_sel(Addr_mux_sel),
        .clk(clk),
        .rst(rst),
        .r_data(mem_read_data),
        .address(mem_address),      
        .w_data(mem_write_data),    
        .Row_counter_out(Row_counter_out),
        .element_cointer_out(element_cointer_out),
        .Bit_counter_out(Bit_counter_out)
    );

endmodule

