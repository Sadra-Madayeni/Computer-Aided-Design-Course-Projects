module rand_controller(
    input clk, rst, start,
    input [2:0] shift_count, 
    output load, shift_en, xor_en, done
);
    wire q_idle, q_load, q_x1, q_x2, q_sh, q_done;
    wire any, w1, w2;

    my_or o1(q_load, q_x1, w1);
    my_or o2(q_x2, q_sh, w2);
    my_or o3(w2, q_done, any);
    
    wire is_idle;
    wire d_load;
    wire active_states;

    my_or oall(w1, w2, active_states);

    wire is_idle_state;

    my_not ni(active_states, is_idle_state);
    
    my_and a_st(is_idle_state, start, d_load);
    
    wire d_x1 = q_load;
    wire d_x2 = q_x1;
    wire d_sh_in = q_x2;
    
    wire c3;
    wire nb2; my_not nb(shift_count[2], nb2);
    wire b01; my_and ab(shift_count[1], shift_count[0], b01);
    my_and a3(b01, nb2, c3);
    
    wire d_done; my_and adn(q_sh, c3, d_done);
    wire not_3; my_not n3(c3, not_3);
    wire loop_sh; my_and als(q_sh, not_3, loop_sh);  
    wire d_sh; my_or osh(d_sh_in, loop_sh, d_sh);
    
    s2 f_ld(.D01(d_load), .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_load), .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_x1(.D01(d_x1),   .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_x1),   .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_x2(.D01(d_x2),   .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_x2),   .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_sh(.D01(d_sh),   .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_sh),   .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    s2 f_dn(.D01(d_done), .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(q_done), .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
    
    assign load = q_load;
    my_or ox(q_x1, q_x2, xor_en);
    assign shift_en = q_sh;
    assign done = q_done;
endmodule