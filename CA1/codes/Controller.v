module Cntrlr(
    input  wire clk,  
    input  wire rst,
    input  wire start,
    input  wire Co,
    input  wire Done_rnd,
    output reg  A_sel,
    output reg  B_sel,
    output reg  C_Sel,
    output reg  D_Sel,
    output reg  Regs_en,
    output reg  m_en,
    output reg  en_counter,
    output reg  Sel,
    output reg  F_en,
    output reg  Start_rnd,
    output reg  Done,
    output reg en_c
);


    parameter IDLE   = 3'b000; 
    parameter STARTED = 3'b001; 
    parameter THIRD  = 3'b010; 
    parameter FOUR   = 3'b011;  
    parameter FIVE   = 3'b100; 
    parameter SIX    = 3'b101; 
    parameter SEVEN  = 3'b110; 
    parameter eight = 3'b111; 

    reg [2:0] ps, ns;

    always @(posedge clk or posedge rst) begin
        if (rst)
            ps <= IDLE;
        else
            ps <= ns;
    end

    always @(*) begin
        ns = ps;  // default

        case (ps)
            IDLE: begin
                if (start)
                    ns = STARTED;
            end

            STARTED: ns = THIRD;

            THIRD: ns = FOUR;

            FOUR: ns = FIVE;

            FIVE: ns = SIX;

            SIX: begin
                if (Done_rnd)
                    ns = SEVEN;
            end

            SEVEN: begin
                if (Co)
                    ns = IDLE;
                else
                    ns = FOUR;
            end

            default: ns = IDLE;
        endcase
    end

    always @(*) begin
        A_sel      = 1'b1;
        B_sel      = 1'b1;
        C_Sel      = 1'b1;
        D_Sel      = 1'b1;
        Regs_en    = 1'b0;
        m_en       = 1'b0;
        en_counter = 1'b0;
        Sel        = 1'b0;
        F_en       = 1'b0;
        Start_rnd  = 1'b0;
        Done       = 1'b0;
        en_c       = 1'b0;

        case (ps)
            STARTED: begin
                m_en = 1'b1;
            end
            THIRD: begin
                Regs_en = 1'b1;
            end

            FOUR: begin
                Sel = 1'b1;
                F_en = 1'b1;
            end

            FIVE: begin
                Start_rnd = 1'b1;
            end

            SIX: begin
                if (Done_rnd) begin
                    m_en    = 1'b1;
                    Sel     = 1'b0;
                    F_en    = 1'b1;
                    A_sel   = 1'b0;
                    B_sel   = 1'b0;
                    C_Sel   = 1'b0;
                    D_Sel   = 1'b0;
                    Regs_en = 1'b1;
                end
            end

            SEVEN: begin
                en_c = 1'b1;
                if (Co)
                    Done = 1'b1;
            end
        endcase
    end

endmodule
