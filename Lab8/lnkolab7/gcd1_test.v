`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:18:11 10/27/2017
// Design Name:   gcd1
// Module Name:   D:/Turorudi/Lab8/lnkolab7/gcd1_test.v
// Project Name:  lnkolab7
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: gcd1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module gcd1_test;

	// Outputs
	input clk;
	input rst;
	
	

	// Instantiate the Unit Under Test (UUT)
	gcd1 uut (
		.()
	);

	initial begin
		// Initialize Inputs

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#110 rst=1;
		#100 rst=0;

	end
	always
		begin
		#50 clk = ~clk;
		end
      
endmodule

