module rand_dp(
    input clk, rst, load, shift_en, xor_en,
    input [5:0] data_in,
    output [5:0] data_out,
    output [1:0] result,
    output [2:0] shift_count_out
);
    
    wire [5:0] s_curr, s_next;
    wire x1, xr;

    my_xor gx1(s_curr[5], s_curr[3], x1);
    my_xor gx2(x1, s_curr[1], xr);
    
    wire [5:0] v_xor = {s_curr[4:0], xr};
    wire [5:0] v_sh  = {s_curr[4:0], 1'b0};
    
    wire [5:0] w1, w2;
    genvar k;
    generate
        for(k=0; k<6; k=k+1) begin: mrand
            my_mux2 mx1(shift_en, s_curr[k], v_sh[k], w1[k]);
            my_mux2 mx2(xor_en, w1[k], v_xor[k], w2[k]);
            my_mux2 mx3(load, w2[k], data_in[k], s_next[k]);
            
            s2 ff (.D01(s_next[k]), .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(s_curr[k]), 
                   .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
        end
    endgenerate
    
    wire [2:0] c_curr, c_next, c_inc;
    wire c0n, c1n, c2n, c1a0;
    my_not n0(c_curr[0], c0n);
    my_xor xc1(c_curr[1], c_curr[0], c1n);
    my_and ac1(c_curr[1], c_curr[0], c1a0);
    my_xor xc2(c_curr[2], c1a0, c2n);
    assign c_inc = {c2n, c1n, c0n};
    
    wire [2:0] wc;
    generate
        for(k=0; k<3; k=k+1) begin: mcnt
            my_mux2 mc1(shift_en, c_curr[k], c_inc[k], wc[k]);
            my_mux2 mc2(load, wc[k], 1'b0, c_next[k]);
            
            s2 ffc (.D01(c_next[k]), .A0(1'b1), .B0(1'b1), .clr(rst), .clk(clk), .out(c_curr[k]),
                    .D00(1'b0), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0));
        end
    endgenerate
    
    assign data_out = s_curr;
    assign result = s_curr[5:4];
    assign shift_count_out = c_curr;
endmodule