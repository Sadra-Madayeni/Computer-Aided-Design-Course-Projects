// Generated at: 2026-01-02 14:29:38
module datapath(
  input clk, rst,
  input [31:0] i1,
  input [31:0] i2,
  input [31:0] i3,
  input [31:0] i4,
  input [31:0] i5,
  input [31:0] i6,
  input [31:0] i7,
  input [31:0] i8,
  input [3:0] alu1_sel1, alu1_sel2,
  input alu1_op,
  input [3:0] alu2_sel1, alu2_sel2,
  input alu2_op,
  input [3:0] alu3_sel1, alu3_sel2,
  input alu3_op,
  input [3:0] alu4_sel1, alu4_sel2,
  input alu4_op,
  input result_en, done_next,
  input reg_alu2_en,
  input reg_alu5_en,
  input reg_alu6_en,
  input reg_alu9_en,
  input reg_alu12_en,
  input reg_alu13_en,
  input reg_alu14_en,
  output reg [31:0] result,
  output reg done
);

  // Intermediate Registers
  reg [31:0] reg_alu2;
  reg [31:0] reg_alu5;
  reg [31:0] reg_alu6;
  reg [31:0] reg_alu9;
  reg [31:0] reg_alu12;
  reg [31:0] reg_alu13;
  reg [31:0] reg_alu14;

  // Functional Units Wires
  reg [31:0] alu1_op1, alu1_op2;
  reg [31:0] alu1_out;
  reg [31:0] alu2_op1, alu2_op2;
  reg [31:0] alu2_out;
  reg [31:0] alu3_op1, alu3_op2;
  reg [31:0] alu3_out;
  reg [31:0] alu4_op1, alu4_op2;
  reg [31:0] alu4_out;

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
      4'd7: alu1_op1 = i8;
      4'd8: alu1_op1 = reg_alu2;
      4'd9: alu1_op1 = reg_alu5;
      4'd10: alu1_op1 = reg_alu6;
      4'd11: alu1_op1 = reg_alu9;
      4'd12: alu1_op1 = reg_alu12;
      4'd13: alu1_op1 = reg_alu13;
      4'd14: alu1_op1 = reg_alu14;
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
      4'd7: alu1_op2 = i8;
      4'd8: alu1_op2 = reg_alu2;
      4'd9: alu1_op2 = reg_alu5;
      4'd10: alu1_op2 = reg_alu6;
      4'd11: alu1_op2 = reg_alu9;
      4'd12: alu1_op2 = reg_alu12;
      4'd13: alu1_op2 = reg_alu13;
      4'd14: alu1_op2 = reg_alu14;
      default: alu1_op2 = 0;
    endcase
  end
  always @(*) begin
    case (alu2_sel1)
      4'd0: alu2_op1 = i1;
      4'd1: alu2_op1 = i2;
      4'd2: alu2_op1 = i3;
      4'd3: alu2_op1 = i4;
      4'd4: alu2_op1 = i5;
      4'd5: alu2_op1 = i6;
      4'd6: alu2_op1 = i7;
      4'd7: alu2_op1 = i8;
      4'd8: alu2_op1 = reg_alu2;
      4'd9: alu2_op1 = reg_alu5;
      4'd10: alu2_op1 = reg_alu6;
      4'd11: alu2_op1 = reg_alu9;
      4'd12: alu2_op1 = reg_alu12;
      4'd13: alu2_op1 = reg_alu13;
      4'd14: alu2_op1 = reg_alu14;
      default: alu2_op1 = 0;
    endcase
  end
  always @(*) begin
    case (alu2_sel2)
      4'd0: alu2_op2 = i1;
      4'd1: alu2_op2 = i2;
      4'd2: alu2_op2 = i3;
      4'd3: alu2_op2 = i4;
      4'd4: alu2_op2 = i5;
      4'd5: alu2_op2 = i6;
      4'd6: alu2_op2 = i7;
      4'd7: alu2_op2 = i8;
      4'd8: alu2_op2 = reg_alu2;
      4'd9: alu2_op2 = reg_alu5;
      4'd10: alu2_op2 = reg_alu6;
      4'd11: alu2_op2 = reg_alu9;
      4'd12: alu2_op2 = reg_alu12;
      4'd13: alu2_op2 = reg_alu13;
      4'd14: alu2_op2 = reg_alu14;
      default: alu2_op2 = 0;
    endcase
  end
  always @(*) begin
    case (alu3_sel1)
      4'd0: alu3_op1 = i1;
      4'd1: alu3_op1 = i2;
      4'd2: alu3_op1 = i3;
      4'd3: alu3_op1 = i4;
      4'd4: alu3_op1 = i5;
      4'd5: alu3_op1 = i6;
      4'd6: alu3_op1 = i7;
      4'd7: alu3_op1 = i8;
      4'd8: alu3_op1 = reg_alu2;
      4'd9: alu3_op1 = reg_alu5;
      4'd10: alu3_op1 = reg_alu6;
      4'd11: alu3_op1 = reg_alu9;
      4'd12: alu3_op1 = reg_alu12;
      4'd13: alu3_op1 = reg_alu13;
      4'd14: alu3_op1 = reg_alu14;
      default: alu3_op1 = 0;
    endcase
  end
  always @(*) begin
    case (alu3_sel2)
      4'd0: alu3_op2 = i1;
      4'd1: alu3_op2 = i2;
      4'd2: alu3_op2 = i3;
      4'd3: alu3_op2 = i4;
      4'd4: alu3_op2 = i5;
      4'd5: alu3_op2 = i6;
      4'd6: alu3_op2 = i7;
      4'd7: alu3_op2 = i8;
      4'd8: alu3_op2 = reg_alu2;
      4'd9: alu3_op2 = reg_alu5;
      4'd10: alu3_op2 = reg_alu6;
      4'd11: alu3_op2 = reg_alu9;
      4'd12: alu3_op2 = reg_alu12;
      4'd13: alu3_op2 = reg_alu13;
      4'd14: alu3_op2 = reg_alu14;
      default: alu3_op2 = 0;
    endcase
  end
  always @(*) begin
    case (alu4_sel1)
      4'd0: alu4_op1 = i1;
      4'd1: alu4_op1 = i2;
      4'd2: alu4_op1 = i3;
      4'd3: alu4_op1 = i4;
      4'd4: alu4_op1 = i5;
      4'd5: alu4_op1 = i6;
      4'd6: alu4_op1 = i7;
      4'd7: alu4_op1 = i8;
      4'd8: alu4_op1 = reg_alu2;
      4'd9: alu4_op1 = reg_alu5;
      4'd10: alu4_op1 = reg_alu6;
      4'd11: alu4_op1 = reg_alu9;
      4'd12: alu4_op1 = reg_alu12;
      4'd13: alu4_op1 = reg_alu13;
      4'd14: alu4_op1 = reg_alu14;
      default: alu4_op1 = 0;
    endcase
  end
  always @(*) begin
    case (alu4_sel2)
      4'd0: alu4_op2 = i1;
      4'd1: alu4_op2 = i2;
      4'd2: alu4_op2 = i3;
      4'd3: alu4_op2 = i4;
      4'd4: alu4_op2 = i5;
      4'd5: alu4_op2 = i6;
      4'd6: alu4_op2 = i7;
      4'd7: alu4_op2 = i8;
      4'd8: alu4_op2 = reg_alu2;
      4'd9: alu4_op2 = reg_alu5;
      4'd10: alu4_op2 = reg_alu6;
      4'd11: alu4_op2 = reg_alu9;
      4'd12: alu4_op2 = reg_alu12;
      4'd13: alu4_op2 = reg_alu13;
      4'd14: alu4_op2 = reg_alu14;
      default: alu4_op2 = 0;
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
    case (alu2_op)
      1'b0: alu2_out = alu2_op1 + alu2_op2; // ADD
      1'b1: alu2_out = alu2_op1 - alu2_op2; // SUB
      default: alu2_out = 0;
    endcase
  end
  always @(*) begin
    case (alu3_op)
      1'b0: alu3_out = alu3_op1 + alu3_op2; // ADD
      1'b1: alu3_out = alu3_op1 - alu3_op2; // SUB
      default: alu3_out = 0;
    endcase
  end
  always @(*) begin
    case (alu4_op)
      1'b0: alu4_out = alu4_op1 + alu4_op2; // ADD
      1'b1: alu4_out = alu4_op1 - alu4_op2; // SUB
      default: alu4_out = 0;
    endcase
  end

  // Registers Update Logic
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      done <= 0;
      result <= 0;
      reg_alu2 <= 0;
      reg_alu5 <= 0;
      reg_alu6 <= 0;
      reg_alu9 <= 0;
      reg_alu12 <= 0;
      reg_alu13 <= 0;
      reg_alu14 <= 0;
    end else begin
      done <= done_next;
      if (reg_alu2_en) reg_alu2 <= alu1_out;
      if (reg_alu5_en) reg_alu5 <= alu2_out;
      if (reg_alu6_en) reg_alu6 <= alu1_out;
      if (reg_alu9_en) reg_alu9 <= alu3_out;
      if (reg_alu12_en) reg_alu12 <= alu4_out;
      if (reg_alu13_en) reg_alu13 <= alu2_out;
      if (reg_alu14_en) reg_alu14 <= alu1_out;
      if (result_en) result <= reg_alu14;
    end
  end
endmodule