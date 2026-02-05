module dataPath(en_c, Done_rnd,start_rnd,msg,start,A_sel, B_sel, C_sel, D_sel,clk,rst,load,shift_en,xor_en,F_sel,en_regs,en_m,en_F,a0,b0,c0,d0,data_in,digest,cout
);

input clk,rst,load,shift_en,xor_en, start,start_rnd, Done_rnd;
input A_sel,B_sel,C_sel,D_sel,F_sel,en_regs,en_m,en_F, en_c;
input [31:0] a0,b0,c0,d0;
input [127:0] msg;
input [5:0] data_in;


output [127:0] digest;
output cout;

// wire [5:0] step_value;
wire [1:0] result;
wire [5:0] data_out;
wire [31:0] muxA_out,muxB_out,muxC_out,muxD_out,regA_out,regB_out,regC_out,regD_out;
wire [31:0] firstMux_in,secondMux_in,thirdMux_in,fourthMux_in,mux_4to1_out,F_rule_out,F_out,Add1_out,Add2_out,Add3_out;
wire [31:0] M0_out,M1_out,M2_out,M3_out,muxM_out,constRom,left_rotate_out,L_add_out;
wire [5:0] counter_out;


top_rand r_dp(clk,rst,start_rnd,counter_out,data_out,result,Done_rnd); 

mux_2to1 #(32) mux_A(muxA_out,A_sel,regD_out,a0);
mux_2to1 #(32) mux_B(muxB_out,B_sel,L_add_out,b0);
mux_2to1 #(32) mux_C(muxC_out,C_sel,regB_out,c0);
mux_2to1 #(32) mux_D(muxD_out,D_sel,regC_out,d0);

register #(32) reg_A(clk,rst,en_regs,muxA_out,regA_out);
register #(32) reg_B(clk,rst,en_regs,muxB_out,regB_out);
register #(32) reg_C(clk,rst,en_regs,muxC_out,regC_out);
register #(32) reg_D(clk,rst,en_regs,muxD_out,regD_out);

assign firstMux_in = ((regB_out & regC_out) | ((~regB_out) & regD_out));
assign secondMux_in = ((regD_out & regB_out) | ((~regD_out) & regC_out));
assign thirdMux_in = regB_out ^ regC_out ^ regD_out;
assign fourthMux_in = (regC_out ^ (regB_out | (~regD_out)));

mux_4to1 #(32) mux_logic(firstMux_in,secondMux_in,thirdMux_in,fourthMux_in,counter_out[5:4],mux_4to1_out);  
counter #(6) count_for_sel(rst,en_c,clk,counter_out,cout);
mux_2to1 #(32) mux_F_rule(F_rule_out,F_sel,Add1_out,mux_4to1_out);
register #(32) F(clk,rst,en_F,mux_4to1_out,F_out);

adder #(32) first_Add(F_out,Add2_out,Add1_out);
adder #(32) second_Add(regA_out,Add3_out,Add2_out);
adder #(32) third_Add(muxM_out,constRom,Add3_out);

const_rom rom(counter_out,constRom);                                    

register #(32) M0(clk,rst,en_m,msg[127:96],M0_out);
register #(32) M1(clk,rst,en_m,msg[95:64],M1_out);
register #(32) M2(clk,rst,en_m,msg[63:32],M2_out);
register #(32) M3(clk,rst,en_m,msg[31:0],M3_out);

mux_4to1 #(32) mux_M(M0_out,M1_out,M2_out,M3_out,result,muxM_out);

// left_rotate LR(F_out,step_value,left_rotate_out);
left_rotate LR(Add1_out,counter_out,left_rotate_out);

adder #(32) L_add(regB_out,left_rotate_out,L_add_out);

assign digest = {regA_out,regB_out,regC_out,regD_out};

endmodule
