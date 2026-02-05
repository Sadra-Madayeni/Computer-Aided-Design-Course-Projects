module shift_accumulator
#(
  parameter WIDTH = 8 
)
(
  input wire clk, 
  input wire rst_n, 
  input wire en,
  input wire load,       
  input wire [WIDTH-1:0] data_in, 
  output reg [WIDTH-1:0] data_out  
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_out <= {WIDTH{1'b0}}; 
    end
    else if (load) begin    
      data_out <= data_in;
    end
    else if (en) begin      
      data_out <= (data_out << 1) + data_in; 
    end
    
  end
endmodule