`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 4 bites szinkron törölhetõ, tölthetõ, engedélyezhetõ, felfelé/lefelé számláló
// BCD számláló mindkét számolási irányban végérték jelzéssel
//////////////////////////////////////////////////////////////////////////////////
module BCDCNT(
    input clk,
    input rst,
    input en,
    output reg [3:0] q,
    output tc
    );

wire ill, q9;
assign ill = (q  > 4'd9);                            // Illegális állapot
assign q9  = (q == 4'd9);                            // Végérték felfelé                          // Végérték lefelé

always @ (posedge clk)                             // Felfutó élre mûködik
   begin
      if (rst | ill)          q <= 4'd0;           // Resetnél vagy illegális   
               else                                // Ha nincs RST, ILL vagy LOAD,
                  if (en)                       
																	
                     if (q9)  q <= 4'd0;          
                     else     q <= q + 4'd1;       
   end
   
     
assign tc = en & (q9);                  


endmodule
