`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:36:25 10/19/2017 
// Design Name: 
// Module Name:    Topmodule 
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
module Topmodule(
	 input [2:0] bt,
	 input clk,
	 //input [4:0] col_n,
	 output [7:0] seg_n,
	 output [3:0] dig_n
    );
	 
wire [1:0] s;
wire [3:0] anzeiger;
wire [3:0] muxout;
wire [7:0] negout;
wire [15:0] muxin;
wire tc1;
wire tc2;
wire tc3;
wire tc4;

cnt3 Meincnt3(.clk(clk), .rst(bt[2]), .q(s));

DEK_2_4 MeinDEK_2_4 (.s(s), .dig(anzeiger));

controller_7_Seg Meincontroller (.data(muxout), .out(seg));

BCDCNT einerBCD (.clk(clk), .rst(bt[2]), .en(bt[1]), .q(muxin[3:0]), .tc(tc1));

BCDCNT zehnerBCD (.clk(clk), .rst(bt[2]), .en(bt[1]), .q(muxin[7:04]), .tc(tc2));

BCDCNT hunderterBCD (.clk(clk), .rst(bt[2]), .en(bt[1]), .q(muxin[11:8]), .tc(tc3));

BCDCNT tausenderBCD (.clk(clk), .rst(bt[2]), .en(bt[1]), .q(muxin[15:12]), .tc(tc4));

MUX MeinMUX (.data(muxin), .s(s), .out(muxout));

assign dig_n = ~anzeiger;

assign seg_n = ~seg;

endmodule
