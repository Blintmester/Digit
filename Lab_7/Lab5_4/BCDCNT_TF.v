`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// BCDCNT tesztkörnyezete
////////////////////////////////////////////////////////////////////////////////

module BCDCNT_TF;

	// Inputs
	reg clk;
	reg rst;
	reg load;
	reg en;
	reg dir;
	reg [3:0] d;

	// Outputs
	wire [3:0] q;
	wire tc;

	// Instantiate the Unit Under Test (UUT)
	BCDCNT uut (
		.clk(clk), 
		.rst(rst), 
		.load(load), 
		.en(en), 
		.dir(dir), 
		.d(d), 
		.q(q), 
		.tc(tc)
	);
   
////////////////////////////////////////////////////////////////////////////////
// Órajel generátor 10MHz frekvenciával
////////////////////////////////////////////////////////////////////////////////

always 
   begin
      #50 clk = ~clk;
   end 


	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		load = 0;
		en = 0;
		dir = 0;
		d = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
      #100 rst = 1;
      #100 rst = 0; en = 1;
      #1200 dir = 1;
      #900 load = 1; d = 4'h3;
      #400 load = 0; en = 0;
      #300 en = 1;

	end
      
endmodule

