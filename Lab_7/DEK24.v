`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:20:30 10/19/2017 
// Design Name: 
// Module Name:    DEK24 
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
module DEK_2_4(
	input [1:0] s,
	output reg [3:0] dig
    );
	 
always @ (*)
	begin
		case (s)
			2'b00: dig <= 4'b0001;
			2'b01: dig <= 4'b0010;
			2'b10: dig <= 4'b0100;
			2'b11: dig <= 4'b1000;
		endcase
	end
endmodule
