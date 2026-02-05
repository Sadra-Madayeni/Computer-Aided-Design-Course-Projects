module my_not(input inp, output out);
    c1 inv (.A0(1'b1), .A1(1'b0), .SA(inp), .B0(1'b0), .B1(1'b0), .SB(1'b0), .S0(1'b0), .S1(1'b0), .f(out));
endmodule

module my_and(input a, input b, output out);
    c1 and_g (.A0(1'b0), .A1(b), .SA(a), .B0(1'b0), .B1(1'b0), .SB(1'b0), .S0(1'b0), .S1(1'b0), .f(out));
endmodule

module my_or(input a, input b, output out);
    c1 or_g (.A0(b), .A1(1'b1), .SA(a), .B0(1'b0), .B1(1'b0), .SB(1'b0), .S0(1'b0), .S1(1'b0), .f(out));
endmodule

module my_xor(input a, input b, output out);
    c2 xor_g (.D00(1'b0), .D01(1'b1), .D10(1'b1), .D11(1'b0), .A1(a), .B1(1'b0), .A0(b), .B0(1'b1), .out(out));
endmodule

module my_mux2(input s, input i0, input i1, output out);
    c1 mux (.A0(i0), .A1(i1), .SA(s), .B0(1'b0), .B1(1'b0), .SB(1'b0), .S0(1'b0), .S1(1'b0), .f(out));
endmodule

module my_mux4_one_cell(input [1:0] s, input i0, i1, i2, i3, output out);
    c1 mux4 (
        .S0(s[1]), .S1(1'b0),      
        .SA(s[0]), .A0(i0), .A1(i1), 
        .SB(s[0]), .B0(i2), .B1(i3), 
        .f(out)
    );
endmodule

module half_adder(input a, input b, output sum, output cout);
    my_xor x1(a, b, sum);
    my_and a1(a, b, cout);
endmodule

module full_adder(input a, input b, input cin, output sum, output cout);
    wire not_cin;
    my_not n1(cin, not_cin);
    c2 sum_lut (.D00(cin), .D01(not_cin), .D10(not_cin), .D11(cin), .A1(a), .B1(1'b0), .A0(b), .B0(1'b1), .out(sum));
    c2 cout_lut (.D00(1'b0), .D01(cin), .D10(cin), .D11(1'b1), .A1(a), .B1(1'b0), .A0(b), .B0(1'b1), .out(cout));
endmodule

module my_adder8(input [7:0] A, input [7:0] B, output [7:0] Sum);
    wire [7:0] c;
    full_adder fa0(A[0], B[0], 1'b0, Sum[0], c[0]);
    full_adder fa1(A[1], B[1], c[0], Sum[1], c[1]);
    full_adder fa2(A[2], B[2], c[1], Sum[2], c[2]);
    full_adder fa3(A[3], B[3], c[2], Sum[3], c[3]);
    full_adder fa4(A[4], B[4], c[3], Sum[4], c[4]);
    full_adder fa5(A[5], B[5], c[4], Sum[5], c[5]);
    full_adder fa6(A[6], B[6], c[5], Sum[6], c[6]);
    full_adder fa7(A[7], B[7], c[6], Sum[7], c[7]);
endmodule

module my_multiplier(input [3:0] A, input [3:0] B, output [7:0] Product);
    wire [3:0] pp0, pp1, pp2, pp3;
    genvar i;
    generate
        for(i=0; i<4; i=i+1) begin: pps
            my_and a0(A[i], B[0], pp0[i]);
            my_and a1(A[i], B[1], pp1[i]);
            my_and a2(A[i], B[2], pp2[i]);
            my_and a3(A[i], B[3], pp3[i]);
        end
    endgenerate

    wire [7:0] s1; wire [3:0] c1;
    assign s1[0] = pp0[0];
    half_adder ha1(pp0[1], pp1[0], s1[1], c1[0]); 
    full_adder fa2(pp0[2], pp1[1], c1[0], s1[2], c1[1]);
    full_adder fa3(pp0[3], pp1[2], c1[1], s1[3], c1[2]);
    
    wire sum4_l1, cout4_l1;
    half_adder ha_opt(.a(pp1[3]), .b(c1[2]), .sum(sum4_l1), .cout(cout4_l1));
    assign s1[4] = sum4_l1;
    assign c1[3] = cout4_l1;
    assign s1[5] = c1[3]; 

    wire [7:0] s2; wire [3:0] c2;
    assign s2[0] = s1[0]; assign s2[1] = s1[1];
    half_adder ha2_2(s1[2], pp2[0], s2[2], c2[0]);
    full_adder fa2_3(s1[3], pp2[1], c2[0], s2[3], c2[1]);
    full_adder fa2_4(s1[4], pp2[2], c2[1], s2[4], c2[2]);
    full_adder fa2_5(s1[5], pp2[3], c2[2], s2[5], c2[3]);
    assign s2[6] = c2[3];
    
    wire [3:0] c3;
    assign Product[0] = s2[0]; assign Product[1] = s2[1]; assign Product[2] = s2[2];
    half_adder ha3_3(s2[3], pp3[0], Product[3], c3[0]);
    full_adder fa3_4(s2[4], pp3[1], c3[0], Product[4], c3[1]);
    full_adder fa3_5(s2[5], pp3[2], c3[1], Product[5], c3[2]);
    full_adder fa3_6(s2[6], pp3[3], c3[2], Product[6], c3[3]);
    assign Product[7] = c3[3];
endmodule


module my_Reg8(
    input clk, rst, en, 
    input sel,          
    input [7:0] i0,     
    input [7:0] i1,     
    output [7:0] q
);
    genvar i;
    generate
        for(i=0; i<8; i=i+1) begin: bits
            
            s2 ff (
                .D00(q[i]), .D01(q[i]), 
                .D10(i0[i]), .D11(i1[i]),
                .A1(en),  .B1(1'b0),
                .A0(sel), .B0(1'b1),
                .clr(rst), .clk(clk), .out(q[i])
            );
        end
    endgenerate
endmodule

module my_reg8(input clk, rst, en, input [7:0] d, output [7:0] q);
    my_Reg8 r(.clk(clk), .rst(rst), .en(en), .sel(1'b0), .i0(d), .i1(d), .q(q));
endmodule

module my_mux4_8bit(input [1:0] s, input [7:0] i0, i1, i2, i3, output [7:0] out);
    genvar i;
    generate
        for(i=0; i<8; i=i+1) begin: m
            my_mux4_one_cell mx(s, i0[i], i1[i], i2[i], i3[i], out[i]);
        end
    endgenerate
endmodule

module my_mux2_8bit(input s, input [7:0] i0, input [7:0] i1, output [7:0] out);
    genvar i;
    generate
        for(i=0; i<8; i=i+1) begin: m
            my_mux2 mx(s, i0[i], i1[i], out[i]);
        end
    endgenerate
endmodule

module my_incrementer6(input [5:0] in, output [5:0] out, output cout);
    wire [5:0] c;
    my_not n0(in[0], out[0]); assign c[0] = in[0];
    half_adder h1(in[1], c[0], out[1], c[1]);
    half_adder h2(in[2], c[1], out[2], c[2]);
    half_adder h3(in[3], c[2], out[3], c[3]);
    half_adder h4(in[4], c[3], out[4], c[4]);
    half_adder h5(in[5], c[4], out[5], c[5]);
    assign cout = c[5]; 
endmodule

module counter(input clk, rst, en, output [5:0] cnt, output cout);
    wire [5:0] curr, next;
    genvar i;
    generate
        for(i=0; i<6; i=i+1) begin: reg_c
             s2 ff (.D00(curr[i]), .D01(next[i]), .D10(1'b0), .D11(1'b0), 
                    .A1(1'b0), .B1(1'b0), .A0(en), .B0(1'b1), 
                    .clr(rst), .clk(clk), .out(curr[i]));
        end
    endgenerate

    wire co_inc;
    my_incrementer6 inc(curr, next, co_inc);
    
    assign cnt = curr;
    
    wire a1, a2, a3, a4;
    my_and g1(cnt[0], cnt[1], a1);
    my_and g2(cnt[2], cnt[3], a2);
    my_and g3(cnt[4], cnt[5], a3);
    my_and g4(a1, a2, a4);
    my_and g5(a4, a3, cout);
endmodule

module f(input [7:0] B, C, D, input [1:0] sel, output [7:0] F);
    wire [7:0] f0, f1, f2, f3;
    genvar k;
    generate
        for(k=0; k<8; k=k+1) begin: lu
            my_mux2 m0(.s(B[k]), .i0(D[k]), .i1(C[k]), .out(f0[k]));
            my_mux2 m1(.s(D[k]), .i0(C[k]), .i1(B[k]), .out(f1[k]));
            
            wire x1; my_xor xor1(B[k], C[k], x1); my_xor xor2(x1, D[k], f2[k]);
            
            wire b_or_nd; my_mux2 m_bnd(.s(D[k]), .i0(1'b1), .i1(B[k]), .out(b_or_nd));
            my_xor x3(C[k], b_or_nd, f3[k]);
        end
    endgenerate
    
    my_mux4_8bit mxf(sel, f0, f1, f2, f3, F);
endmodule