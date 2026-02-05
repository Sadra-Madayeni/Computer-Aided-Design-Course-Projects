module dataPath(
    input clk, rst,
    input A_sel, B_sel, C_sel, D_sel, F_sel,
    input en_regs, en_m, en_F, en_c,
    input [7:0] a0, b0, c0, d0,
    input [31:0] msg,
    output [5:0] counter_out,
    output cout,
    output [31:0] digest
);

    wire [7:0] muxA_out, muxB_out, muxC_out, muxD_out;
    wire [7:0] regA_out, regB_out, regC_out, regD_out;
    wire [7:0] firstMux_in, secondMux_in, thirdMux_in, fourthMux_in;
    wire [7:0] mux_4to1_out, F_rule_out, F_out;
    wire [7:0] Add1_out, Add2_out, Add3_out, L_add_out;
    wire [7:0] M0_out, M1_out, M2_out, M3_out, muxM_out;
    wire [7:0] constRom; 
    wire [7:0] multiplier_out;

    register #(8) M0(clk, rst, en_m, msg[31:24], M0_out);
    register #(8) M1(clk, rst, en_m, msg[23:16], M1_out);
    register #(8) M2(clk, rst, en_m, msg[15:8],  M2_out);
    register #(8) M3(clk, rst, en_m, msg[7:0],   M3_out);

    mux_4to1 #(8) mux_M(M0_out, M1_out, M2_out, M3_out, counter_out[1:0], muxM_out);

    const_rom rom(counter_out, constRom);

    mux_2to1 #(8) mux_A(muxA_out, A_sel, regD_out, a0);
    mux_2to1 #(8) mux_B(muxB_out, B_sel, L_add_out, b0);
    mux_2to1 #(8) mux_C(muxC_out, C_sel, regB_out, c0);
    mux_2to1 #(8) mux_D(muxD_out, D_sel, regC_out, d0);

    register #(8) reg_A(clk, rst, en_regs, muxA_out, regA_out);
    register #(8) reg_B(clk, rst, en_regs, muxB_out, regB_out);
    register #(8) reg_C(clk, rst, en_regs, muxC_out, regC_out);
    register #(8) reg_D(clk, rst, en_regs, muxD_out, regD_out);

    assign firstMux_in  = (regB_out & regC_out) | (~regB_out & regD_out);
    assign secondMux_in = (regD_out & regB_out) | (~regD_out & regC_out);
    assign thirdMux_in  = regB_out ^ regC_out ^ regD_out;
    assign fourthMux_in = regC_out ^ (regB_out | ~regD_out);

    mux_4to1 #(8) mux_logic(firstMux_in, secondMux_in, thirdMux_in, fourthMux_in, counter_out[5:4], mux_4to1_out);

    mux_2to1 #(8) mux_F_rule(F_rule_out, F_sel, Add1_out, mux_4to1_out);
    register #(8) F(clk, rst, en_F, mux_4to1_out, F_out); 

    adder #(8) third_Add(muxM_out, constRom, Add3_out);
    adder #(8) second_Add(regA_out, Add3_out, Add2_out);
    adder #(8) first_Add(F_out, Add2_out, Add1_out); 

    
    wire [3:0] half1 = Add1_out[7:4];
    wire [3:0] half2 = Add1_out[3:0];
    assign multiplier_out = half1 * half2; 

    adder #(8) L_add(regB_out, multiplier_out, L_add_out);

    counter #(6) count_for_sel(rst, en_c, clk, counter_out, cout);
    assign digest = {regA_out, regB_out, regC_out, regD_out};

endmodule