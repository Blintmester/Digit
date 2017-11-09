`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:26:19 10/26/2017 
// Design Name: 
// Module Name:    GGT 
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
module GGT(
    input rst,
    input [1:0] bt,
    input [7:0] a,
    input [7:0] b,
    output [7:0] ggt,
    input [0:0] clk
    );

/// Zustandbenennung
parameter IDLE = 3'd0;
parameter INITA = 3'd1;
parameter INITB = 3'd2;
parameter TEST = 3'd3;
parameter EXCH = 3'd4;
parameter SUB = 3'd5;
parameter READY = 3'd6;
 

/// Steuerungssignale
wire loada;
wire excha;
wire updta;
wire loadb;
wire exchb;

reg [2:0] state, next_state;

assign loada = bt[0];
assign loadb = bt[1];
assign excha = (state == EXCH);
assign exchb = (state == EXCH);
assign updta = (state == SUB);

//Statussignale
wire agtb;
wire aeqb;
wire bgta;

assign agtb = (a > b);
assign bgta = (a < b);
assign aeqb = (a == b);

wire [2:0] status;
assign status = {agtb, bgta, aeqb};


/// Zustanduebergebe
always @ (posedge clk)
	if (rst) state <= IDLE;
	else 		state <= next_state;
	
/// Next_state Logik
always @ (*)
begin
	case (state)
		IDLE: 	if (loada)  next_state <= INITA;
					else 		   next_state <= IDLE;
		INITA: 	if (loadb)  next_state <= INITB;
					else 		   next_state <= INITA;
		INITB:				   next_state <= TEST;
		TEST: 	case(status)
						3'b001:	next_state <= READY;
						3'b010:	next_state <= EXCH;
						3'b100:	next_state <= SUB;
						default: next_state <= IDLE;
					endcase
		SUB:						next_state <= TEST;
		EXCH:						next_state <= SUB;
		READY:					next_state <= IDLE;
	endcase
end

always @ (posedge clk)
	if (rst) state <= IDLE;
	else 		state <= next_state;


/// hier kommt die Datenstruktur

reg [7:0] aout, bout;
wire [7:0] diff;

/// Subtrahierung
assign diff = aout - bout;

// Register a
always @ (posedge clk)
begin
	if (rst)		aout <= 8'b0;
	else if (loada)	aout <= a;
	else if (excha)	aout <= bout;
	else if (updta)	aout <= diff;	
end

// Register b
always @ (posedge clk)
begin
	if (rst)		bout <= 8'b0;
	else if (loadb)	bout <= b;
	else if (exchb)	bout <= aout;
end

assign ggt = (state == READY) ? aout : 8'b0;

endmodule
