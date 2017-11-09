`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:31:48 10/19/2017 
// Design Name: 
// Module Name:    MUX 
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
module MUX(
	 input [15:0] data,
    input [1:0] s,
    output reg [3:0] out
    );

always @ (*)
	begin 
		case (s)
			2'b00: out <= data[3:0];
			2'b01: out <= data[7:4];
			2'b10: out <= data[11:8];
			2'b11: out <= data[15:12];
		endcase
	end
endmodule
