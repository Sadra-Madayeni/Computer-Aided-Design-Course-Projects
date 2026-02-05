
module FDCP(
input clk , CLR, D, 
output reg Q);

    always @(posedge clk or posedge CLR)
        if(CLR)
        Q <= 0;
        else
        Q <= D;
endmodule


module s1(input D00 , D01 ,D10 , D11 , A1 , B1 , A0 , clr , clk , output out);
    initial begin 
    $system("s2-s1.exe ");
    end
    wire s0 , s1 ,d; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & clr ;
    assign d= ({s1,s0}== 2'd0)? D00: 
            ({s1,s0}==2'd1)? D01: 
            ({s1,s0}==2'd2)? D10: 
            ({s1,s0}==2'd3)? D11 :
                    2'bz;
    FDCP ff(clk , clr , d, out) ;

endmodule


module s2(input D00 , D01 ,D10 , D11 , A1 , B1 , A0,B0 , clr , clk , output out);
initial begin 
    $system("s2-s1.exe ");
    end
    wire s0 , s1 ,d; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & B0;
    assign d= ({s1,s0}== 2'd0)? D00: 
            ({s1,s0}==2'd1)? D01: 
            ({s1,s0}==2'd2)? D10: 
            ({s1,s0}==2'd3)? D11 :
                    2'bz;
    FDCP ff (clk , clr , d, out) ;     
endmodule


module c1(input A0 , A1 , SA , B0 , B1 ,SB , S0 , S1,output f);
    initial begin 
    $system("c1.exe ");
    end
    wire f1 , f2 , s2; 
    assign f1 = (SA)? A1:A0;
    assign f2 = (SB)? B1:B0;
    assign s2 = S0|S1;
    assign f=(s2)?f2:f1;
endmodule

