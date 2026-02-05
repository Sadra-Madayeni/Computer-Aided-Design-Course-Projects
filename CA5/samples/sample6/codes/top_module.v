// Generated at: 2026-01-02 14:29:38
module top_module(
  input clk, rst, start,
  input [31:0] i1,
  input [31:0] i2,
  input [31:0] i3,
  input [31:0] i4,
  input [31:0] i5,
  input [31:0] i6,
  input [31:0] i7,
  input [31:0] i8,
  output [31:0] result,
  output done
);

  wire op_ready, done_next, result_en;
  wire [3:0] alu1_sel1, alu1_sel2;
  wire alu1_op;
  wire [3:0] alu2_sel1, alu2_sel2;
  wire alu2_op;
  wire [3:0] alu3_sel1, alu3_sel2;
  wire alu3_op;
  wire [3:0] alu4_sel1, alu4_sel2;
  wire alu4_op;
  wire reg_alu2_en;
  wire reg_alu5_en;
  wire reg_alu6_en;
  wire reg_alu9_en;
  wire reg_alu12_en;
  wire reg_alu13_en;
  wire reg_alu14_en;

  controller ctrl_inst (
    .clk(clk), .rst(rst), .start(start),
    .op_ready(op_ready), .done_next(done_next), .result_en(result_en),
    .alu1_sel1(alu1_sel1), .alu1_sel2(alu1_sel2), .alu1_op(alu1_op),
    .alu2_sel1(alu2_sel1), .alu2_sel2(alu2_sel2), .alu2_op(alu2_op),
    .alu3_sel1(alu3_sel1), .alu3_sel2(alu3_sel2), .alu3_op(alu3_op),
    .alu4_sel1(alu4_sel1), .alu4_sel2(alu4_sel2), .alu4_op(alu4_op),
    .reg_alu2_en(reg_alu2_en),
    .reg_alu5_en(reg_alu5_en),
    .reg_alu6_en(reg_alu6_en),
    .reg_alu9_en(reg_alu9_en),
    .reg_alu12_en(reg_alu12_en),
    .reg_alu13_en(reg_alu13_en),
    .reg_alu14_en(reg_alu14_en)
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
    .i8(i8),
    .done_next(done_next), .result_en(result_en), .result(result), .done(done),
    .alu1_sel1(alu1_sel1), .alu1_sel2(alu1_sel2), .alu1_op(alu1_op),
    .alu2_sel1(alu2_sel1), .alu2_sel2(alu2_sel2), .alu2_op(alu2_op),
    .alu3_sel1(alu3_sel1), .alu3_sel2(alu3_sel2), .alu3_op(alu3_op),
    .alu4_sel1(alu4_sel1), .alu4_sel2(alu4_sel2), .alu4_op(alu4_op),
    .reg_alu2_en(reg_alu2_en),
    .reg_alu5_en(reg_alu5_en),
    .reg_alu6_en(reg_alu6_en),
    .reg_alu9_en(reg_alu9_en),
    .reg_alu12_en(reg_alu12_en),
    .reg_alu13_en(reg_alu13_en),
    .reg_alu14_en(reg_alu14_en)
  );
endmodule