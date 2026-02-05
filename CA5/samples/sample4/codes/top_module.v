// Generated at: 2026-01-02 14:29:31
module top_module(
  input clk, rst, start,
  input [31:0] i1,
  input [31:0] i2,
  input [31:0] i3,
  input [31:0] i4,
  input [31:0] i5,
  input [31:0] i6,
  input [31:0] i7,
  output [31:0] result,
  output done
);

  wire op_ready, done_next, result_en;
  wire [3:0] alu1_sel1, alu1_sel2;
  wire alu1_op;
  wire [3:0] mul1_sel1, mul1_sel2;
  wire mul1_op;
  wire reg_mul2_en;
  wire reg_alu4_en;
  wire reg_mul6_en;
  wire reg_alu8_en;
  wire reg_mul10_en;
  wire reg_alu12_en;

  controller ctrl_inst (
    .clk(clk), .rst(rst), .start(start),
    .op_ready(op_ready), .done_next(done_next), .result_en(result_en),
    .alu1_sel1(alu1_sel1), .alu1_sel2(alu1_sel2), .alu1_op(alu1_op),
    .mul1_sel1(mul1_sel1), .mul1_sel2(mul1_sel2), .mul1_op(mul1_op),
    .reg_mul2_en(reg_mul2_en),
    .reg_alu4_en(reg_alu4_en),
    .reg_mul6_en(reg_mul6_en),
    .reg_alu8_en(reg_alu8_en),
    .reg_mul10_en(reg_mul10_en),
    .reg_alu12_en(reg_alu12_en)
  );

  datapath dp_inst (
    .clk(clk), .rst(rst),
    .i1(i1),
    .i2(i2),
    .i3(i3),
    .i4(i4),
    .i5(i5),
    .i6(i6),
    .i7(i7),
    .done_next(done_next), .result_en(result_en), .result(result), .done(done),
    .alu1_sel1(alu1_sel1), .alu1_sel2(alu1_sel2), .alu1_op(alu1_op),
    .mul1_sel1(mul1_sel1), .mul1_sel2(mul1_sel2), .mul1_op(mul1_op),
    .reg_mul2_en(reg_mul2_en),
    .reg_alu4_en(reg_alu4_en),
    .reg_mul6_en(reg_mul6_en),
    .reg_alu8_en(reg_alu8_en),
    .reg_mul10_en(reg_mul10_en),
    .reg_alu12_en(reg_alu12_en)
  );
endmodule