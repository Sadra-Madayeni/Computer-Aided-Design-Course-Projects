// Generated at: 2026-01-02 14:29:31
module datapath(
  input clk, rst,
  input [31:0] i1,
  input [31:0] i2,
  input [31:0] i3,
  input [31:0] i4,
  input [31:0] i5,
  input [31:0] i6,
  input [31:0] i7,
  input [3:0] alu1_sel1, alu1_sel2,
  input alu1_op,
  input [3:0] mul1_sel1, mul1_sel2,
  input mul1_op,
  input result_en, done_next,
  input reg_mul2_en,
  input reg_alu4_en,
  input reg_mul6_en,
  input reg_alu8_en,
  input reg_mul10_en,
  input reg_alu12_en,
  output reg [31:0] result,
  output reg done
);

  // Intermediate Registers
  reg [31:0] reg_mul2;
  reg [31:0] reg_alu4;
  reg [31:0] reg_mul6;
  reg [31:0] reg_alu8;
  reg [31:0] reg_mul10;
  reg [31:0] reg_alu12;

  // Functional Units Wires
  reg [31:0] alu1_op1, alu1_op2;
  reg [31:0] alu1_out;
  reg [31:0] mul1_op1, mul1_op2;
  reg [31:0] mul1_out;

  // MUX Logic
  always @(*) begin
    case (alu1_sel1)
      4'd0: alu1_op1 = i1;
      4'd1: alu1_op1 = i2;
      4'd2: alu1_op1 = i3;
      4'd3: alu1_op1 = i4;
      4'd4: alu1_op1 = i5;
      4'd5: alu1_op1 = i6;
      4'd6: alu1_op1 = i7;
      4'd7: alu1_op1 = reg_mul2;
      4'd8: alu1_op1 = reg_alu4;
      4'd9: alu1_op1 = reg_mul6;
      4'd10: alu1_op1 = reg_alu8;
      4'd11: alu1_op1 = reg_mul10;
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
      4'd6: alu1_op2 = i7;
      4'd7: alu1_op2 = reg_mul2;
      4'd8: alu1_op2 = reg_alu4;
      4'd9: alu1_op2 = reg_mul6;
      4'd10: alu1_op2 = reg_alu8;
      4'd11: alu1_op2 = reg_mul10;
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
      4'd6: mul1_op1 = i7;
      4'd7: mul1_op1 = reg_mul2;
      4'd8: mul1_op1 = reg_alu4;
      4'd9: mul1_op1 = reg_mul6;
      4'd10: mul1_op1 = reg_alu8;
      4'd11: mul1_op1 = reg_mul10;
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
      4'd6: mul1_op2 = i7;
      4'd7: mul1_op2 = reg_mul2;
      4'd8: mul1_op2 = reg_alu4;
      4'd9: mul1_op2 = reg_mul6;
      4'd10: mul1_op2 = reg_alu8;
      4'd11: mul1_op2 = reg_mul10;
      4'd12: mul1_op2 = reg_alu12;
      default: mul1_op2 = 0;
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

  // Registers Update Logic
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      done <= 0;
      result <= 0;
      reg_mul2 <= 0;
      reg_alu4 <= 0;
      reg_mul6 <= 0;
      reg_alu8 <= 0;
      reg_mul10 <= 0;
      reg_alu12 <= 0;
    end else begin
      done <= done_next;
      if (reg_mul2_en) reg_mul2 <= mul1_out;
      if (reg_alu4_en) reg_alu4 <= alu1_out;
      if (reg_mul6_en) reg_mul6 <= mul1_out;
      if (reg_alu8_en) reg_alu8 <= alu1_out;
      if (reg_mul10_en) reg_mul10 <= mul1_out;
      if (reg_alu12_en) reg_alu12 <= alu1_out;
      if (result_en) result <= reg_alu12;
    end
  end
endmodule