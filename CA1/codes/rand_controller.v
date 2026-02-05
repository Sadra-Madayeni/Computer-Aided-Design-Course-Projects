module controller(
    input clk,
    input rst,
    input start,
    output reg load,
    output reg shift_en,
    output reg xor_en,
    output reg done
);

    parameter IDLE        = 3'b000;
    parameter LOAD        = 3'b001;
    parameter XOR_SHIFT1  = 3'b010;
    parameter XOR_SHIFT2  = 3'b011;
    parameter SHIFT_STAGE = 3'b100;
    parameter FINISH      = 3'b101;
    parameter HOLD_RESULT = 3'b110;

    reg [2:0] ps, ns;          
    reg [2:0] shift_count;      

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ps <= IDLE;
            shift_count <= 3'b000;
        end else begin
            ps<= ns;
    
            if (ps == SHIFT_STAGE)
                shift_count <= shift_count + 1;
            else if (ps == LOAD)
                shift_count <= 3'b000;
        end
    end

    always @(*) begin
        ns = ps;
        case (ps)
            IDLE: begin
                if (start)
                    ns = LOAD;
            end

            LOAD:        ns = XOR_SHIFT1;   
            XOR_SHIFT1:  ns = XOR_SHIFT2;
            XOR_SHIFT2:  ns = SHIFT_STAGE;

            SHIFT_STAGE: begin
                if (shift_count == 3'b011)
                    ns = HOLD_RESULT;
                else
                    ns = SHIFT_STAGE; 
            end

            HOLD_RESULT: ns = FINISH;
            FINISH:      ns = IDLE;

            default:     ns = IDLE;
        endcase
    end

    always @(*) begin
        load = 1'b0;
        shift_en = 1'b0;
        xor_en = 1'b0;
        done = 1'b0;

        case (ps)
            LOAD:        load = 1'b1;
            XOR_SHIFT1:  xor_en = 1'b1;
            XOR_SHIFT2:  xor_en = 1'b1;
            SHIFT_STAGE: shift_en = 1'b1;
            FINISH:      done = 1'b1;
        endcase
    end

endmodule
