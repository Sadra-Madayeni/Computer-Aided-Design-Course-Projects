module tb_PE_stripes;

  
  parameter N  = 4;
  parameter W  = 16;
  parameter MP = 16;
  localparam OUT_WIDTH = W + $clog2(N) + MP;
  
  localparam CLK_PERIOD = 10; 

  
  reg clk;
  reg rst_n;
  reg i_valid;
  reg i_is_msb;
  reg i_is_lsb;
  reg [N-1:0]     i_vec_a_bits;
  reg [N*W-1:0]   i_vec_b;
  reg [OUT_WIDTH-1:0] i_initial_sum;

  
  wire [OUT_WIDTH-1:0] o_dot_product;
  
  
  reg signed [MP-1:0] A [N-1:0]; 
  reg signed [W-1:0]  B [N-1:0]; 

  
  PE_stripes #(
    .N(N),
    .W(W),
    .MP(MP)
  ) 
  DUT (
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(i_valid),
    .i_is_msb(i_is_msb),
    .i_is_lsb(i_is_lsb),
    .i_vec_a_bits(i_vec_a_bits),
    .i_vec_b(i_vec_b),
    .i_initial_sum(i_initial_sum),
    .o_dot_product(o_dot_product)
  );

  
  always begin
    clk = 0; #(CLK_PERIOD / 2);
    clk = 1; #(CLK_PERIOD / 2);
  end

  
  integer j; 
  integer i; 
  
  initial begin
    $display("--- [TB] Starting Testbench for PE_stripes ---");
    $display("--- [TB] Testing: [1, -4, 6, 3] . [2, 6, -1, 7] = -7 ---");


    A[0] = 16'd1;
    A[1] = -16'd4;
    A[2] = 16'd6;
    A[3] = 16'd3;

    
    B[0] = 16'd2;
    B[1] = 16'd6;
    B[2] = -16'd1;
    B[3] = 16'd7;
    
    
    for (i = 0; i < N; i = i + 1) begin
      i_vec_b[(i*W) +: W] = B[i];
    end
    
    i_initial_sum = 34'd0; 
    
    rst_n   = 1;
    i_valid = 0;
    i_is_msb = 0;
    i_is_lsb = 0;
    i_vec_a_bits = 0;
    
    #(CLK_PERIOD * 2);
    $display("[TB] Asserting Reset (rst_n=0)");
    rst_n = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    $display("[TB] De-asserting Reset (rst_n=1)");
    #(CLK_PERIOD);


    $display("[TB] Starting bit-serial loop (%0d cycles)...", MP);
    

    for (j = MP-1; j >= 0; j = j - 1) begin
      @(posedge clk);
      
     
      i_valid = 1;
      i_is_msb = (j == MP-1); 
      i_is_lsb = (j == 0);    

      
      for (i = 0; i < N; i = i + 1) begin
        i_vec_a_bits[i] = A[i][j]; 
      end

      $display("[TB] Cycle %2d (Bit %2d): i_vec_a_bits = %b, MSB=%b, LSB=%b", 
               (MP-1-j), j, i_vec_a_bits, i_is_msb, i_is_lsb);
               
     
      if (i_is_lsb) begin
        #(1); 
        $display("-------------------------------------------------");
        $display("[TB] LSB Cycle: Checking final result...");
        $display("[TB] Expected Result: %d", -34'd7);
        $display("[TB] Actual Result:   %d", $signed(o_dot_product));
        
        if ($signed(o_dot_product) == -34'd7) begin
          $display("\n[*** TEST PASSED ***]");
        end else begin
          $display("\n[!!! TEST FAILED !!!]");
        end
        $display("-------------------------------------------------");
      end
    end
    

    @(posedge clk);
    i_valid = 0;
    $display("[TB] Computation complete. Stopping simulation.");
    $finish;
  end

endmodule