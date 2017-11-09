`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:22:47 10/19/2017 
// Design Name: 
// Module Name:    cnt3 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cnt3(
	input clk,
	input rst,
	output reg [1:0] q
    );
	 
always @ (posedge clk)
	begin
		if (rst) q <= 2'b0;
		else q <= q + 2'b1;
	end
endmodule
