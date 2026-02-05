module Controller (
   
    input wire clk,
    input wire rst,
    input wire start,
    input wire [2:0] Row_counter_out,
    input wire [2:0] element_cointer_out,
    input wire [3:0] Bit_counter_out,

    output reg Row_en,
    output reg Bit_en,
    output reg element_en,
    output reg vec_a_en,
    output reg PE1_B_en,
    output reg PE2_B_en,
    output reg element_clr, 
    output reg Bit_clr,     
    output reg w_data_en,   
    output reg i_valid,
    output reg i_is_lsb,
    output reg i_is_msb,
    output reg [1:0] Addr_mux_sel,
    output reg write,
    output reg done
);

    localparam [2:0]
        S_IDLE        = 3'b000,
        S_LOAD_A      = 3'b001,
        S_LOAD_B      = 3'b010,
        S_CALCULATE   = 3'b011,
        S_WRITE_O     = 3'b100,
        S_CHECK_ROW   = 3'b101,
        S_DONE        = 3'b110,
        S_START_PULSE = 3'b111; 

    reg [2:0] current_state, next_state;

    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    
    always @(*) begin
        next_state = current_state; 
        case (current_state)
            S_IDLE: begin
                if (start) begin
                    next_state = S_START_PULSE; 
                end
            end
            
        
            S_START_PULSE: begin
                next_state = S_LOAD_A;
            end
           
            
            S_LOAD_A: begin
                if (element_cointer_out == 3'd7) begin
                    next_state = S_LOAD_B;
                end
            end
            S_LOAD_B: begin
                if (element_cointer_out == 3'd7) begin
                    next_state = S_CALCULATE;
                end
            end
            S_CALCULATE: begin
                if (Bit_counter_out == 4'd15) begin 
                    next_state = S_WRITE_O;
                end
            end
            S_WRITE_O: begin
                next_state = S_CHECK_ROW;
            end
            S_CHECK_ROW: begin
                if (Row_counter_out == 3'd7) begin
                    next_state = S_DONE;
                end else begin
                    next_state = S_LOAD_B;
                end
            end
            
            
            S_DONE: begin
                if (!start) begin 
                    next_state = S_IDLE;
                end
               
            end
            
            default: begin 
                next_state = S_IDLE;
            end
        endcase
    end

    
    always @(*) begin
        
        Row_en          = 1'b0;
        Bit_en          = 1'b0;
        element_en      = 1'b0;
        vec_a_en        = 1'b0;
        PE1_B_en        = 1'b0;
        PE2_B_en        = 1'b0;
        element_clr     = 1'b0;
        Bit_clr         = 1'b0;
        w_data_en       = 1'b0;
        i_valid         = 1'b0;
        i_is_lsb        = 1'b0;
        i_is_msb        = 1'b0;
        Addr_mux_sel    = 2'b00;
        write           = 1'b0;
        done            = 1'b0;

       
        case (current_state)
            S_IDLE: begin

                if (start) begin
                    element_clr = 1'b1;
                end
            end
            
           
            S_START_PULSE: begin
             
            end
            
            
            S_LOAD_A: begin
                element_en      = 1'b1;
                Addr_mux_sel    = 2'b00;
                vec_a_en        = 1'b1;
                
                if (element_cointer_out == 3'd7) begin
                    element_clr = 1'b1;
                end
            end
            
            S_LOAD_B: begin
                element_en      = 1'b1;
                Addr_mux_sel    = 2'b01;
                
                if (element_cointer_out < 3'd4) begin
                    PE1_B_en = 1'b1;
                end else begin
                    PE2_B_en = 1'b1;
                end

                if (element_cointer_out == 3'd7) begin
                    Bit_clr = 1'b1;
                end
            end
            
            S_CALCULATE: begin
                Bit_en          = 1'b1;
                i_valid         = 1'b1;
                
                if (Bit_counter_out == 4'd0) begin
                    i_is_msb = 1'b1;
                end
                if (Bit_counter_out == 4'd15) begin
                    i_is_lsb = 1'b1;
                    w_data_en = 1'b1; 
                end
            end
            
            S_WRITE_O: begin
                Addr_mux_sel    = 2'b10;
                write           = 1'b1;
            end
            
            S_CHECK_ROW: begin
                Row_en = 1'b1;
            end
            
            S_DONE: begin
                done = 1'b1; 
            end
            
            default: begin
               
            end
        endcase
    end

endmodule

