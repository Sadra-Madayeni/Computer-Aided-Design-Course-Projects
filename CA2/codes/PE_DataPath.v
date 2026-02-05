module PE_stripes#(parameter N  = 4,parameter W  = 16,parameter MP = 16)
(
  input wire clk, input wire rst_n, input wire i_valid,
  input wire i_is_msb, input wire i_is_lsb,
  input wire [N-1:0]     i_vec_a_bits,
  input wire [N*W-1:0]   i_vec_b,
  
  input wire [W + $clog2(N) + MP - 1 : 0] i_initial_sum,
  output wire [W + $clog2(N) + MP - 1 : 0] o_dot_product
);

  localparam OUT_WIDTH = W + $clog2(N) + MP;


  wire [W-1:0] B     [N-1:0];
  wire [W-1:0] B_neg [N-1:0];
  wire [W-1:0] mux_out [N-1:0];
  wire [W-1:0] pp_unextended [N-1:0];
  wire [OUT_WIDTH-1:0] pp[N-1:0];
  wire [OUT_WIDTH-1:0] pp_sum_total;
  wire [OUT_WIDTH-1:0] final_mux_out;
  wire [OUT_WIDTH-1:0] acc_out_wire; 
  wire [OUT_WIDTH-1:0] shifted_acc_out;
  wire [OUT_WIDTH-1:0] acc_reg_next;
  wire [OUT_WIDTH+2:0] pp_sum_wide; 

  genvar i;

  generate
    for (i = 0; i < N; i = i + 1) begin : gen_datapath_lane

      assign B[i] = i_vec_b[(i*W) +: W];

      parametric_twos_comp_classic #(.WIDTH(W)) 

      twos_comp_inst (.in_a(B[i]), .out_neg(B_neg[i]));

      mux_2to1 #(.WIDTH(W)) pp_mux_inst (.f(mux_out[i]), .s(i_is_msb), .a(B[i]), .b(B_neg[i]));

      
      assign pp_unextended[i] = i_vec_a_bits[i] ? mux_out[i] : {W{1'b0}};

      assign pp[i] = {{OUT_WIDTH-W{pp_unextended[i][W-1]}}, pp_unextended[i]};
    end
  endgenerate
  
  
  parametric_5_input_adder #(.WIDTH(OUT_WIDTH)) pp_adder_inst (.in_a(pp[0]),.in_b(pp[1]),.in_c(pp[2]),.in_d(pp[3]),.in_e({OUT_WIDTH{1'b0}}),.sum(pp_sum_wide));
  
  assign pp_sum_total = pp_sum_wide[OUT_WIDTH-1:0];

  shift_accumulator #(.WIDTH(OUT_WIDTH)) main_acc_inst (.clk(clk),.rst_n(rst_n),.en(i_valid && !i_is_msb),.load(i_valid && i_is_msb),.data_in(pp_sum_total),.data_out(acc_out_wire));

  assign shifted_acc_out = acc_out_wire << 1;

  adder #(.WIDTH(OUT_WIDTH)) acc_next_state_calc_adder (.a(pp_sum_total),.b(shifted_acc_out),.sum(acc_reg_next));
   
  mux_2to1 #(.WIDTH(OUT_WIDTH))final_mux_inst (.f(final_mux_out), .s(i_is_lsb),.a({OUT_WIDTH{1'b0}}),.b(i_initial_sum));
 
  adder #(.WIDTH(OUT_WIDTH))final_adder_inst (.a(acc_reg_next),.b(final_mux_out), .sum(o_dot_product));

endmodule