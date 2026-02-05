module TopModule(
    input clk, rst, start,
    input [7:0] a0, b0, c0, d0,
    input [31:0] msg,
    input [5:0] data_in,
    output Done,
    output [31:0] digest
);
    
    wire A_sel, B_sel, C_sel, D_sel;
    wire Regs_en, m_en, en_c, Sel, F_en, Start_rnd;
    wire Co, Done_rnd;
    wire [1:0] rnd_idx;
    wire [5:0] cnt_wire; 

    controller ctrl (
        .clk(clk), .rst(rst), .start(start),
        .Co(Co), .Done_rnd(Done_rnd),
        .A_sel(A_sel), .B_sel(B_sel), .C_sel(C_sel), .D_sel(D_sel),
        .Regs_en(Regs_en), .m_en(m_en), .en_c(en_c), .en_counter(),
        .Sel(Sel), .F_en(F_en), .Start_rnd(Start_rnd), .Done(Done)
    );

    top_rand rnd_unit (
        .clk(clk), .rst(rst),
        .start(Start_rnd),   
        .data_in(cnt_wire),
        .data_out(),         
        .result(rnd_idx),
        .done(Done_rnd) 
    );


    dataPath dp (
        .clk(clk), .rst(rst), .start(start), 
        .Done_rnd(Done_rnd),
        .rnd_idx(rnd_idx),
        .A_sel(A_sel), .B_sel(B_sel), .C_sel(C_sel), .D_sel(D_sel),
        .en_regs(Regs_en), .en_m(m_en), .en_c(en_c), .F_sel(Sel),
        .a0(a0), .b0(b0), .c0(c0), .d0(d0),
        .msg(msg),       
        .digest(digest), .cout(Co), .cnt_out_wire(cnt_wire)
    );
endmodule