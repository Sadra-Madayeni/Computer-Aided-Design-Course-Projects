module dataPath(
    input clk, rst, start, Done_rnd, 
    input [1:0] rnd_idx, 
    input A_sel, B_sel, C_sel, D_sel, en_regs, en_m, en_c, F_sel,
    input [7:0] a0, b0, c0, d0,
    input [31:0] msg,
    
    output [31:0] digest,
    output cout,
    output [5:0] cnt_out_wire 
);
    wire [7:0] rA, rB, rC, rD;
    wire [7:0] F, K, M;
    wire [7:0] s1, s2, s3, sB, mult;
    wire [5:0] cnt;
    
    assign cnt_out_wire = cnt;
    
    my_Reg8 rgA(.clk(clk), .rst(rst), .en(en_regs), .sel(A_sel), .i0(rD), .i1(a0), .q(rA));
    my_Reg8 rgB(.clk(clk), .rst(rst), .en(en_regs), .sel(B_sel), .i0(sB), .i1(b0), .q(rB));
    my_Reg8 rgC(.clk(clk), .rst(rst), .en(en_regs), .sel(C_sel), .i0(rB), .i1(c0), .q(rC));
    my_Reg8 rgD(.clk(clk), .rst(rst), .en(en_regs), .sel(D_sel), .i0(rC), .i1(d0), .q(rD));
    
    f lu(rB, rC, rD, cnt[5:4], F);
    
    rom Rom(cnt, K);
    
    my_mux4_8bit mxM(rnd_idx, msg[31:24], msg[23:16], msg[15:8], msg[7:0], M);

    my_adder8 ad1(F, rA, s1);
    my_adder8 ad2(s1, K, s2);
    my_adder8 ad3(s2, M, s3); 
    my_multiplier mu(s3[7:4], s3[3:0], mult);
    my_adder8 adB(rB, mult, sB);
    
    counter sc(clk, rst, en_c, cnt, cout);
    
    assign digest = {rA, rB, rC, rD};
endmodule