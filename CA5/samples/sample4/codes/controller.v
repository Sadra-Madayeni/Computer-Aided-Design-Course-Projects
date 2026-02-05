// Generated at: 2026-01-02 14:29:31
module controller(
  input clk, rst, start,
  output reg op_ready, done_next, result_en,
  output reg [3:0] alu1_sel1, alu1_sel2,
  output reg alu1_op,
  output reg [3:0] mul1_sel1, mul1_sel2,
  output reg mul1_op,
  output reg reg_mul2_en,
  output reg reg_alu4_en,
  output reg reg_mul6_en,
  output reg reg_alu8_en,
  output reg reg_mul10_en,
  output reg reg_alu12_en
);

  reg [31:0] state, next_state;
  localparam S_IDLE = 0, S_DONE = 999;
  localparam S_CYCLE_1 = 1;
  localparam S_CYCLE_2 = 2;
  localparam S_CYCLE_3 = 3;
  localparam S_CYCLE_4 = 4;
  localparam S_CYCLE_5 = 5;
  localparam S_CYCLE_6 = 6;

  always @(posedge clk or posedge rst) begin
    if (rst) state <= S_IDLE;
    else state <= next_state;
  end

  always @(*) begin
    next_state = state;
    op_ready = 0; done_next = 0; result_en = 0;
    alu1_sel1 = 0; alu1_sel2 = 0; alu1_op = 0;
    mul1_sel1 = 0; mul1_sel2 = 0; mul1_op = 0;
    reg_mul2_en = 0;
    reg_alu4_en = 0;
    reg_mul6_en = 0;
    reg_alu8_en = 0;
    reg_mul10_en = 0;
    reg_alu12_en = 0;

    case (state)
      S_IDLE: begin
        op_ready = 1;
        if (start) next_state = S_CYCLE_1;
      end
      S_CYCLE_1: begin
        mul1_sel1 = 4'd0;
        mul1_sel2 = 4'd1;
        reg_mul2_en = 1;
        mul1_op = 1'b0;
        next_state = S_CYCLE_2;
      end
      S_CYCLE_2: begin
        alu1_sel1 = 4'd7;
        alu1_sel2 = 4'd2;
        reg_alu4_en = 1;
        alu1_op = 1'b0;
        next_state = S_CYCLE_3;
      end
      S_CYCLE_3: begin
        mul1_sel1 = 4'd8;
        mul1_sel2 = 4'd3;
        reg_mul6_en = 1;
        mul1_op = 1'b0;
        next_state = S_CYCLE_4;
      end
      S_CYCLE_4: begin
        alu1_sel1 = 4'd9;
        alu1_sel2 = 4'd4;
        reg_alu8_en = 1;
        alu1_op = 1'b0;
        next_state = S_CYCLE_5;
      end
      S_CYCLE_5: begin
        mul1_sel1 = 4'd10;
        mul1_sel2 = 4'd5;
        reg_mul10_en = 1;
        mul1_op = 1'b0;
        next_state = S_CYCLE_6;
      end
      S_CYCLE_6: begin
        alu1_sel1 = 4'd11;
        alu1_sel2 = 4'd6;
        reg_alu12_en = 1;
        alu1_op = 1'b0;
        result_en = 1;
        next_state = S_DONE;
      end
      S_DONE: begin
        done_next = 1;
        next_state = S_IDLE;
      end
    endcase
  end
endmodule