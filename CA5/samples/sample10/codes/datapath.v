// Generated at: 2026-01-02 14:29:53
module datapath(
  input clk, rst,
  input [31:0] i1,
  input [31:0] i2,
  input [31:0] i3,
  input [31:0] i4,
  input [31:0] i5,
  input [31:0] i6,
  input [3:0] alu1_sel1, alu1_sel2,
  input alu1_op,
  input [3:0] mul1_sel1, mul1_sel2,
  input mul1_op,
  input [3:0] log1_sel1, log1_sel2,
  input [1:0] log1_op,
  input result_en, done_next,
  input reg_mul2_en,
  input reg_mul5_en,
  input reg_alu6_en,
  input reg_mul7_en,
  input reg_mul10_en,
  input reg_log11_en,
  input reg_alu12_en,
  output reg [31:0] result,
  output reg done
);

  // Intermediate Registers
  reg [31:0] reg_mul2;
  reg [31:0] reg_mul5;
  reg [31:0] reg_alu6;
  reg [31:0] reg_mul7;
  reg [31:0] reg_mul10;
  reg [31:0] reg_log11;
  reg [31:0] reg_alu12;

  // Functional Units Wires
  reg [31:0] alu1_op1, alu1_op2;
  reg [31:0] alu1_out;
  reg [31:0] mul1_op1, mul1_op2;
  reg [31:0] mul1_out;
  reg [31:0] log1_op1, log1_op2;
  reg [31:0] log1_out;

  // MUX Logic
  always @(*) begin
    case (alu1_sel1)
      4'd0: alu1_op1 = i1;
      4'd1: alu1_op1 = i2;
      4'd2: alu1_op1 = i3;
      4'd3: alu1_op1 = i4;
      4'd4: alu1_op1 = i5;
      4'd5: alu1_op1 = i6;
      4'd6: alu1_op1 = reg_mul2;
      4'd7: alu1_op1 = reg_mul5;
      4'd8: alu1_op1 = reg_alu6;
      4'd9: alu1_op1 = reg_mul7;
      4'd10: alu1_op1 = reg_mul10;
      4'd11: alu1_op1 = reg_log11;
      4'd12: alu1_op1 = reg_alu12;
      default: alu1_op1 = 0;
    endcase
  end
  always @(*) begin
    case (alu1_sel2)
      4'd0: alu1_op2 = i1;
      4'd1: alu1_op2 = i2;
      4'd2: alu1_op2 = i3;
      4'd3: alu1_op2 = i4;
      4'd4: alu1_op2 = i5;
      4'd5: alu1_op2 = i6;
      4'd6: alu1_op2 = reg_mul2;
      4'd7: alu1_op2 = reg_mul5;
      4'd8: alu1_op2 = reg_alu6;
      4'd9: alu1_op2 = reg_mul7;
      4'd10: alu1_op2 = reg_mul10;
      4'd11: alu1_op2 = reg_log11;
      4'd12: alu1_op2 = reg_alu12;
      default: alu1_op2 = 0;
    endcase
  end
  always @(*) begin
    case (mul1_sel1)
      4'd0: mul1_op1 = i1;
      4'd1: mul1_op1 = i2;
      4'd2: mul1_op1 = i3;
      4'd3: mul1_op1 = i4;
      4'd4: mul1_op1 = i5;
      4'd5: mul1_op1 = i6;
      4'd6: mul1_op1 = reg_mul2;
      4'd7: mul1_op1 = reg_mul5;
      4'd8: mul1_op1 = reg_alu6;
      4'd9: mul1_op1 = reg_mul7;
      4'd10: mul1_op1 = reg_mul10;
      4'd11: mul1_op1 = reg_log11;
      4'd12: mul1_op1 = reg_alu12;
      default: mul1_op1 = 0;
    endcase
  end
  always @(*) begin
    case (mul1_sel2)
      4'd0: mul1_op2 = i1;
      4'd1: mul1_op2 = i2;
      4'd2: mul1_op2 = i3;
      4'd3: mul1_op2 = i4;
      4'd4: mul1_op2 = i5;
      4'd5: mul1_op2 = i6;
      4'd6: mul1_op2 = reg_mul2;
      4'd7: mul1_op2 = reg_mul5;
      4'd8: mul1_op2 = reg_alu6;
      4'd9: mul1_op2 = reg_mul7;
      4'd10: mul1_op2 = reg_mul10;
      4'd11: mul1_op2 = reg_log11;
      4'd12: mul1_op2 = reg_alu12;
      default: mul1_op2 = 0;
    endcase
  end
  always @(*) begin
    case (log1_sel1)
      4'd0: log1_op1 = i1;
      4'd1: log1_op1 = i2;
      4'd2: log1_op1 = i3;
      4'd3: log1_op1 = i4;
      4'd4: log1_op1 = i5;
      4'd5: log1_op1 = i6;
      4'd6: log1_op1 = reg_mul2;
      4'd7: log1_op1 = reg_mul5;
      4'd8: log1_op1 = reg_alu6;
      4'd9: log1_op1 = reg_mul7;
      4'd10: log1_op1 = reg_mul10;
      4'd11: log1_op1 = reg_log11;
      4'd12: log1_op1 = reg_alu12;
      default: log1_op1 = 0;
    endcase
  end
  always @(*) begin
    case (log1_sel2)
      4'd0: log1_op2 = i1;
      4'd1: log1_op2 = i2;
      4'd2: log1_op2 = i3;
      4'd3: log1_op2 = i4;
      4'd4: log1_op2 = i5;
      4'd5: log1_op2 = i6;
      4'd6: log1_op2 = reg_mul2;
      4'd7: log1_op2 = reg_mul5;
      4'd8: log1_op2 = reg_alu6;
      4'd9: log1_op2 = reg_mul7;
      4'd10: log1_op2 = reg_mul10;
      4'd11: log1_op2 = reg_log11;
      4'd12: log1_op2 = reg_alu12;
      default: log1_op2 = 0;
    endcase
  end

  // Functional Units Implementation
  always @(*) begin
    case (alu1_op)
      1'b0: alu1_out = alu1_op1 + alu1_op2; // ADD
      1'b1: alu1_out = alu1_op1 - alu1_op2; // SUB
      default: alu1_out = 0;
    endcase
  end
  always @(*) begin
    case (mul1_op)
      1'b0: mul1_out = mul1_op1 * mul1_op2; // MULT
      1'b1: mul1_out = mul1_op1 / mul1_op2; // DIV
      default: mul1_out = 0;
    endcase
  end
  always @(*) begin
    case (log1_op)
      2'b00: log1_out = log1_op1 & log1_op2; // AND
      2'b01: log1_out = log1_op1 | log1_op2; // OR
      2'b10: log1_out = log1_op1 ^ log1_op2; // XOR
      default: log1_out = 0;
    endcase
  end

  // Registers Update Logic
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      done <= 0;
      result <= 0;
      reg_mul2 <= 0;
      reg_mul5 <= 0;
      reg_alu6 <= 0;
      reg_mul7 <= 0;
      reg_mul10 <= 0;
      reg_log11 <= 0;
      reg_alu12 <= 0;
    end else begin
      done <= done_next;
      if (reg_mul2_en) reg_mul2 <= mul1_out;
      if (reg_mul5_en) reg_mul5 <= mul1_out;
      if (reg_alu6_en) reg_alu6 <= alu1_out;
      if (reg_mul7_en) reg_mul7 <= mul1_out;
      if (reg_mul10_en) reg_mul10 <= mul1_out;
      if (reg_log11_en) reg_log11 <= log1_out;
      if (reg_alu12_en) reg_alu12 <= alu1_out;
      if (result_en) result <= reg_alu12;
    end
  end
endmodule