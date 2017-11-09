`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:13:17 10/26/2017 
// Design Name: 
// Module Name:    Topmodul 
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
module Topmodul(
    input rst,
    input [1:0] bt,
    input [7:0] sw,
    input clk,
	 input clk16M,
	 output [7:0] seg_n,                  
    output [3:0] dig_n 
    );
	 
wire [7:0] number;
wire [3:0] dig;
wire [7:0] seg;

GGT MeinGGT (.rst(rst), .bt(bt), .a(sw), .b(sw), .clk(clk), .ggt(number));

LIP_4digit MeinLIP (.clk16M(clk16M), .rst(rst), .number({8'b0, number}), .dp(4'b0), .dig(dig), .seg(seg));

assign seg_n = ~seg;
assign dig_n = ~dig;



endmodule
