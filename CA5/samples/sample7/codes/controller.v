// Generated at: 2026-01-02 14:29:41
module controller(
  input clk, rst, start,
  output reg op_ready, done_next, result_en,
  output reg [3:0] mul1_sel1, mul1_sel2,
  output reg mul1_op,
  output reg [3:0] log1_sel1, log1_sel2,
  output reg [1:0] log1_op,
  output reg reg_mul2_en,
  output reg reg_mul4_en,
  output reg reg_mul6_en,
  output reg reg_log9_en,
  output reg reg_log10_en,
  output reg reg_log13_en,
  output reg reg_log14_en
);

  reg [31:0] state, next_state;
  localparam S_IDLE = 0, S_DONE = 999;
  localparam S_CYCLE_1 = 1;
  localparam S_CYCLE_2 = 2;
  localparam S_CYCLE_3 = 3;
  localparam S_CYCLE_4 = 4;
  localparam S_CYCLE_5 = 5;

  always @(posedge clk or posedge rst) begin
    if (rst) state <= S_IDLE;
    else state <= next_state;
  end

  always @(*) begin
    next_state = state;
    op_ready = 0; done_next = 0; result_en = 0;
    mul1_sel1 = 0; mul1_sel2 = 0; mul1_op = 0;
    log1_sel1 = 0; log1_sel2 = 0; log1_op = 0;
    reg_mul2_en = 0;
    reg_mul4_en = 0;
    reg_mul6_en = 0;
    reg_log9_en = 0;
    reg_log10_en = 0;
    reg_log13_en = 0;
    reg_log14_en = 0;

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
        log1_sel1 = 4'd4;
        log1_sel2 = 4'd5;
        reg_log9_en = 1;
        log1_op = 2'd0;
        next_state = S_CYCLE_2;
      end
      S_CYCLE_2: begin
        mul1_sel1 = 4'd8;
        mul1_sel2 = 4'd2;
        reg_mul4_en = 1;
        mul1_op = 1'b0;
        log1_sel1 = 4'd6;
        log1_sel2 = 4'd7;
        reg_log13_en = 1;
        log1_op = 2'd0;
        next_state = S_CYCLE_3;
      end
      S_CYCLE_3: begin
        mul1_sel1 = 4'd9;
        mul1_sel2 = 4'd3;
        reg_mul6_en = 1;
        mul1_op = 1'b0;
        next_state = S_CYCLE_4;
      end
      S_CYCLE_4: begin
        log1_sel1 = 4'd10;
        log1_sel2 = 4'd11;
        reg_log10_en = 1;
        log1_op = 2'd1;
        next_state = S_CYCLE_5;
      end
      S_CYCLE_5: begin
        log1_sel1 = 4'd12;
        log1_sel2 = 4'd13;
        reg_log14_en = 1;
        log1_op = 2'd1;
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