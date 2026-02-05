module TopModule (
    input clk,
    input rst,
    input start,
    input [7:0] a0, b0, c0, d0,
    input [31:0] msg,
    output Done,
    output [31:0] digest
);


    wire A_sel, B_sel, C_Sel, D_Sel;
    wire Regs_en, m_en, en_c, Sel, F_en;
    wire [5:0] count;
    wire cout;

    dataPath dp (
        .clk(clk),
        .rst(rst),
        .A_sel(A_sel), 
        .B_sel(B_sel), 
        .C_sel(C_Sel), 
        .D_sel(D_Sel),
        .F_sel(Sel),
        .en_regs(Regs_en), 
        .en_m(m_en), 
        .en_F(F_en), 
        .en_c(en_c),
        .a0(a0), 
        .b0(b0), 
        .c0(c0), 
        .d0(d0),
        .msg(msg),
        .counter_out(count),
        .cout(cout),
        .digest(digest)
    );

    Cntrlr controller (
        .clk(clk),
        .rst(rst),
        .start(start),
        .Co(cout),
        .A_sel(A_sel), 
        .B_sel(B_sel), 
        .C_Sel(C_Sel), 
        .D_Sel(D_Sel),
        .Regs_en(Regs_en), 
        .m_en(m_en), 
        .en_counter(),
        .Sel(Sel), 
        .F_en(F_en),
        .Done(Done),
        .en_c(en_c)
    );

endmodule