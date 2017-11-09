`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:32:42 10/27/2017 
// Design Name: 
// Module Name:    gcd1 
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
module gcd1(
    );

wire [7:0] diff;
assign diff= ao - bo;

always @ (posedge clk)
	begin
	if(rst)		ao <= 8'b0;
	else
		if (loada)		ao<=ai;
		else
			if (excha)  ao<=bo;
			else
				if (upda) ao<=diff;
	end
	
always @ (posedge clk)
	begin
		if (rst) bo<=8'b0;
		else
			if (loadb) bo<=bi;
			else
				if(exchb) bo<=ao;
	end
	
assign agtb = (ao > bo);
assign bgta = (bo > ao);
assign aeqb = (ao == bo);

parameter IDLE = 3'b000;
parameter INIT = 3'b001;
parameter TEST = 3'b010;
parameter SUB = 3'b011;
parameter EXCH = 3'b100;
parameter READY = 3'b101;

reg [2:0] state, nextstate;

always @ (posedge clk)
	begin
		if (rst) state<= IDLE;
			else state<=nextstate;
	end
	
	
	
wire [2:0] status;
assign status = {agtb, bgta, aeqb};

always @ (*)
	case (state)
		IDLE: if (start)		nextstate<= INIT;
					else			nextstate<=IDLE;
					
					
		INIT:						nextstate<= TEST;
		TEST: case (status)
					3'b100:		nextstate<=SUB;
					3'b010:		nextstate<=EXCH;
					3'b001:		nextstate<=READY;
					default:		nextstate<=IDLE;
				endcase
		SUB:						nextstate<=TEST;
		EXCH:						nextstate<=TEST;
		READY:					nextstate<=IDLE;
		default:					nextstate<=IDLE;
	endcase

assign loada = (state == INIT);
assign loadb = (state == INIT);
assign upda = (state == SUB);
assign excha = (state == EXCH);
assign exchb = (state == EXCH);
assign ready = (state == READY);


endmodule
