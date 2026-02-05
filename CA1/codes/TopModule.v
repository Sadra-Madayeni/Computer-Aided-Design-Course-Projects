module TopModule (
    input rst,
    input start,
    input clk,
    input [31:0] a0, b0, c0, d0,
    input [127:0] msg,
    input [5:0] data_in,
    output Done,
    output [127:0] digest
);

    wire A_sel, B_sel, C_Sel, D_Sel, Regs_en, m_en, en_counter, Sel, F_en, Start_rnd, en_c;
    
    wire cout; 
    wire Dore_rnd;
    


    dataPath datapath (
        .en_c(en_c),
        .Done_rnd(Dore_rnd),
        .start_rnd(Start_rnd),
        .start(start),
        .A_sel(A_sel),
        .B_sel(B_sel),
        .C_sel(C_Sel), 
        .D_sel(D_Sel),  
        .clk(clk),
        .rst(rst),
        .load(1'b0),    
        .shift_en(1'b0),
        .xor_en(1'b0),  
        .F_sel(Sel),     
        .en_regs(Regs_en),
        .en_m(m_en),
        .en_F(F_en),
        .a0(a0),
        .b0(b0),
        .c0(c0),
        .d0(d0),
        .msg(msg),
        .data_in(data_in),
        .digest(digest),
        .cout(cout)
    );


    Cntrlr controller (
        .rst(rst),
        .start(start),
        .clk(clk),
        .Co(cout),
        .A_sel(A_sel),
        .B_sel(B_sel),
        .C_Sel(C_Sel),
        .D_Sel(D_Sel),
        .Regs_en(Regs_en),
        .m_en(m_en),
        .en_counter(en_counter),
        .Sel(Sel),
        .F_en(F_en),
        .Start_rnd(Start_rnd),
        .Done_rnd(Dore_rnd),
        .Done(Done),
        .en_c(en_c)
    );

endmodule
