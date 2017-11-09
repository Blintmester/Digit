`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:37:37 10/19/2017 
// Design Name: 
// Module Name:    controller_7_Seg 
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
module controller_7_Seg(
    input [3:0] data,
    output reg [7:0] out
    );

always @ (*)
	begin
		case (data)
			4'd0 : out <= 8'b00111111;
			4'd1 : out <= 8'b00000110;
			4'd2 : out <= 8'b01011011;
			4'd3 : out <= 8'b01001111;
			4'd4 : out <= 8'b01100110;
			4'd5 : out <= 8'b01101101;
			4'd6 : out <= 8'b01111101;
			4'd7 : out <= 8'b00000111;
			4'd8 : out <= 8'b01111111;
			4'd9 : out <= 8'b01101111;
		default	 out <= 8'b00000000;
		endcase
	end
endmodule
