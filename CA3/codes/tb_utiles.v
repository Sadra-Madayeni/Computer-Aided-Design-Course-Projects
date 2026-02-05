`timescale 1ns/1ns

module tb_modules;

    reg clk;
    reg rst;
    integer errors;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg a, b;
    wire w_not, w_and, w_or, w_xor;
    
    my_not u_not(.inp(a), .out(w_not));
    my_and u_and(.a(a), .b(b), .out(w_and));
    my_or  u_or (.a(a), .b(b), .out(w_or));
    my_xor u_xor(.a(a), .b(b), .out(w_xor));

    task check_gates;
        input exp_not, exp_and, exp_or, exp_xor;
        begin
            #1;
            if (w_not !== exp_not) begin $display("Error NOT: inp=%b, got=%b", a, w_not); errors=errors+1; end
            if (w_and !== exp_and) begin $display("Error AND: a=%b, b=%b, got=%b", a, b, w_and); errors=errors+1; end
            if (w_or  !== exp_or)  begin $display("Error OR:  a=%b, b=%b, got=%b", a, b, w_or);  errors=errors+1; end
            if (w_xor !== exp_xor) begin $display("Error XOR: a=%b, b=%b, got=%b", a, b, w_xor); errors=errors+1; end
        end
    endtask


    reg [1:0] sel;
    wire mux_out;
    my_mux4_one_cell u_mux(.s(sel), .i0(1'b0), .i1(1'b1), .i2(1'b1), .i3(1'b0), .out(mux_out));


    reg [7:0] add_a, add_b;
    wire [7:0] sum;
    my_adder8 u_adder(.A(add_a), .B(add_b), .Sum(sum));


    reg [3:0] mul_a, mul_b;
    wire [7:0] prod;
    my_multiplier u_mult(.A(mul_a), .B(mul_b), .Product(prod));


    reg [7:0] f_B, f_C, f_D;
    reg [1:0] f_sel;
    wire [7:0] f_out;
    
    f u_logic(.B(f_B), .C(f_C), .D(f_D), .sel(f_sel), .F(f_out));


    reg cnt_en;
    wire [5:0] cnt_val;
    wire cnt_co;
    
    counter u_cnt(.clk(clk), .rst(rst), .en(cnt_en), .cnt(cnt_val), .cout(cnt_co));

  
    initial begin
    
        errors = 0;
        rst = 1; #10 rst = 0;

     
        a=0; b=0; check_gates(1, 0, 0, 0);
        a=0; b=1; check_gates(1, 0, 1, 1);
        a=1; b=0; check_gates(0, 0, 1, 1);
        a=1; b=1; check_gates(0, 1, 1, 0);
        
    
        #10;
        sel=0; #1; if(mux_out !== 0) begin $display("Error Mux sel=0"); errors=errors+1; end
        sel=1; #1; if(mux_out !== 1) begin $display("Error Mux sel=1"); errors=errors+1; end
        sel=2; #1; if(mux_out !== 1) begin $display("Error Mux sel=2"); errors=errors+1; end
        sel=3; #1; if(mux_out !== 0) begin $display("Error Mux sel=3"); errors=errors+1; end

      
        #10;
        add_a = 10; add_b = 20; #5;
        if(sum !== 30) begin $display("Error Adder: 10+20 != %d", sum); errors=errors+1; end
        
        add_a = 200; add_b = 100; #5; 
        if(sum !== 44) begin $display("Error Adder: 200+100 != %d", sum); errors=errors+1; end

        
        #10;
        mul_a = 3; mul_b = 5; #5;
        if(prod !== 15) begin $display("Error Mult: 3*5 != %d", prod); errors=errors+1; end
        
        mul_a = 15; mul_b = 15; #5;
        if(prod !== 225) begin $display("Error Mult: 15*15 != %d", prod); errors=errors+1; end

      
        f_B=8'h0C; f_C=8'h0A; f_D=8'h06; 
        
 
        f_sel=0; #10; 
        if(f_out !== 8'h0A) begin $display("Error Logic F0: Got %h", f_out); errors=errors+1; end
        
   
        f_sel=1; #10; 
        if(f_out !== 8'h0C) begin $display("Error Logic F1: Got %h", f_out); errors=errors+1; end
        
  
        f_sel=2; #10; 
        if(f_out !== 8'h00) begin $display("Error Logic F2: Got %h", f_out); errors=errors+1; end

        $display("Checking Counter");
        rst = 1; #10 rst = 0;
        cnt_en = 1;
        
       
        wait(cnt_val == 6'd63);
        #1;
        
        if (cnt_co !== 1) begin 
            $display("Error Counter: Cout did not assert at 63!"); 
            errors=errors+1; 
        end else begin
            
            #10;
            if (cnt_val !== 0) begin $display("Error Counter: Did not wrap to 0!"); errors=errors+1; end
        end

        $display("-------------------------------------------");
        if(errors == 0) 
            $display("SUCCESS: ALL MODULES PASSED!");
        else 
            $display("FAILURE: FOUND %0d ERRORS!", errors);
        $display("-------------------------------------------");
        $stop;
    end

endmodule