module controller(
    input clk, rst, start, Co, Done_rnd,
    output A_sel, B_sel, C_sel, D_sel,
    output Regs_en, m_en, en_counter, Sel, F_en, Start_rnd, Done, en_c
);
   
    wire q_idle, q_start, q_third, q_four, q_five, q_six, q_seven, q_eight;
    wire any_act, w1, w2, w3, w4;

    my_or o1(q_start, q_third, w1);
    my_or o2(q_four, q_five, w2);
    my_or o3(q_six, q_seven, w3);
    my_or o4(w1, w2, w4);
    my_or o5(w4, q_eight, any_act);
    wire is_idle;
    my_not n_idle(any_act, is_idle);

    wire d_start; my_and a1(is_idle, start, d_start);
    wire d_third = q_start;
    wire d_four_in = q_third;
    wire not_co; my_not nco(Co, not_co);
    wire loop_back; my_and alp(q_seven, not_co, loop_back);
    wire d_four; my_or o_four(d_four_in, loop_back, d_four);
    
    wire d_five = q_four;
    wire d_six_in = q_five;
    wire not_dr; my_not ndr(Done_rnd, not_dr);
    wire stay_six; my_and asix(q_six, not_dr, stay_six);
    wire d_six; my_or osix(d_six_in, stay_six, d_six);
    wire d_seven; my_and ase(q_six, Done_rnd, d_seven);
    wire d_done; my_and adn(q_seven, Co, d_done);
    
    s2 f_st(.D01(d_start), .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_start), .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_th(.D01(d_third), .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_third), .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_fo(.D01(d_four),  .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_four),  .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_fi(.D01(d_five),  .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_five),  .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_si(.D01(d_six),   .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_six),   .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_se(.D01(d_seven), .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_seven), .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_dn(.D01(d_done),  .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_eight), .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));

    my_or om(q_start, d_seven, m_en);
    my_or ore(q_third, d_seven, Regs_en);
    my_or ofe(q_four, d_seven, F_en);
    
    assign Sel = q_four;
    assign Start_rnd = q_five;
    assign en_c = q_seven;
    assign en_counter = q_seven;
    assign Done = q_eight;
    
    wire is_update;
    assign is_update = d_seven;
    my_not nsel(is_update, A_sel);
    assign B_sel = A_sel;
    assign C_sel = A_sel;
    assign D_sel = A_sel;

endmodule