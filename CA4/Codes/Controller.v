module Cntrlr(
    input  wire clk, rst, start, Co,
    output reg  A_sel, B_sel, C_Sel, D_Sel,
    output reg  Regs_en, m_en, en_counter, Sel, F_en, Done, en_c
);
    parameter IDLE    = 3'b000; 
    parameter STARTED = 3'b001; 
    parameter THIRD   = 3'b010; 
    parameter FOUR    = 3'b011;  
    parameter FIVE    = 3'b100;
    parameter SIX     = 3'b110;

    reg [2:0] ps, ns;

    always @(posedge clk) begin
        if (rst)
            ps <= IDLE;
        else
            ps <= ns;
    end    

    always @(*) begin
        ns = ps;
        case (ps)
            IDLE:    if (start) ns = STARTED;
            STARTED: ns = THIRD;
            THIRD:   ns = FOUR;
            FOUR:    ns = FIVE;
            FIVE:    ns = SIX;
            SIX:   if (Co) ns = IDLE; else ns = FOUR;
            default: ns = IDLE;
        endcase
    end

    always @(*) begin

        A_sel=1; 
        B_sel=1; 
        C_Sel=1; 
        D_Sel=1;
        Regs_en=0; 
        m_en=0; 
        en_counter=0; 
        Sel=0; 
        F_en=0; 
        Done=0; 
        en_c=0;

        case (ps)
            STARTED: m_en = 1; 
            THIRD:   Regs_en = 1;
            FOUR:    begin Sel = 1; F_en = 1; end
            FIVE:    begin 
                        
                        m_en = 1; 
                        Sel = 0; 
                        F_en = 1; 
                        A_sel=0; 
                        B_sel=0; 
                        C_Sel=0; 
                        D_Sel=0;
                        Regs_en=1; 

                     end
            SIX:   begin 
                        en_c = 1; 
                        if (Co) Done = 1;
                     end
        endcase
    end
endmodule