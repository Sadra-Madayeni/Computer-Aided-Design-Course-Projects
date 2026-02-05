// Generated at: 2026-01-02 14:29:21
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
  wire [3:0] mul1_sel1, mul1_sel2;
  wire mul1_op;
  wire [3:0] log1_sel1, log1_sel2;
  wire [1:0] log1_op;
  wire [3:0] log2_sel1, log2_sel2;
  wire [1:0] log2_op;
  wire reg_log2_en;
  wire reg_log5_en;
  wire reg_alu6_en;
  wire reg_log9_en;
  wire reg_log12_en;
  wire reg_alu13_en;
  wire reg_mul14_en;

  controller ctrl_inst (
    .clk(clk), .rst(rst), .start(start),
    .op_ready(op_ready), .done_next(done_next), .result_en(result_en),
    .alu1_sel1(alu1_sel1), .alu1_sel2(alu1_sel2), .alu1_op(alu1_op),
    .mul1_sel1(mul1_sel1), .mul1_sel2(mul1_sel2), .mul1_op(mul1_op),
    .log1_sel1(log1_sel1), .log1_sel2(log1_sel2), .log1_op(log1_op),
    .log2_sel1(log2_sel1), .log2_sel2(log2_sel2), .log2_op(log2_op),
    .reg_log2_en(reg_log2_en),
    .reg_log5_en(reg_log5_en),
    .reg_alu6_en(reg_alu6_en),
    .reg_log9_en(reg_log9_en),
    .reg_log12_en(reg_log12_en),
    .reg_alu13_en(reg_alu13_en),
    .reg_mul14_en(reg_mul14_en)
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
    .mul1_sel1(mul1_sel1), .mul1_sel2(mul1_sel2), .mul1_op(mul1_op),
    .log1_sel1(log1_sel1), .log1_sel2(log1_sel2), .log1_op(log1_op),
    .log2_sel1(log2_sel1), .log2_sel2(log2_sel2), .log2_op(log2_op),
    .reg_log2_en(reg_log2_en),
    .reg_log5_en(reg_log5_en),
    .reg_alu6_en(reg_alu6_en),
    .reg_log9_en(reg_log9_en),
    .reg_log12_en(reg_log12_en),
    .reg_alu13_en(reg_alu13_en),
    .reg_mul14_en(reg_mul14_en)
  );
endmodule