`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 4 bites szinkron t�r�lhet�, t�lthet�, enged�lyezhet�, felfel�/lefel� sz�ml�l�
// BCD sz�ml�l� mindk�t sz�mol�si ir�nyban v�g�rt�k jelz�ssel
//////////////////////////////////////////////////////////////////////////////////
module BCDCNT(
    input clk,
    input rst,
    input en,
    output reg [3:0] q,
    output tc
    );

wire ill, q9;
assign ill = (q  > 4'd9);                            // Illeg�lis �llapot
assign q9  = (q == 4'd9);                            // V�g�rt�k felfel�                          // V�g�rt�k lefel�

always @ (posedge clk)                             // Felfut� �lre m�k�dik
   begin
      if (rst | ill)          q <= 4'd0;           // Resetn�l vagy illeg�lis   
               else                                // Ha nincs RST, ILL vagy LOAD,
                  if (en)                       
																	
                     if (q9)  q <= 4'd0;          
                     else     q <= q + 4'd1;       
   end
   
     
assign tc = en & (q9);                  


endmodule
