module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW); 	
	input  logic         CLOCK_50; // 50MHz clock.	
	output logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 		
	output logic  [9:0]  LEDR; 		
	input  logic  [3:0]  KEY; // True when not pressed, False when pressed	
	input  logic  [9:0]  SW; 			
	
	// Generate clk off of CLOCK_50, whichClock picks rate.	
	
	logic reset;
	logic [31:0] div_clk;	
	
	assign reset = ~KEY[0];
	parameter whichClock = 25;	// 0.75 Hz clock
	clock_divider cdiv (.clock(CLOCK_50),	
                       .reset(reset),	
                       .divided_clocks(div_clk));		
	
	// Clock selection; allows for easy switching between sim and board clocks
	logic clkSelect;

	// Detect when we're in Quartus and use the divided clock,
	// otherwise assume we're in ModelSim and use the fast clock
	`ifdef ALTERA_RESERVED_QIS
	    assign clkSelect = div_clk[whichClock]; // for board
	`else
	    assign clkSelect = CLOCK_50; // for simulation
	`endif

	hazard_lights display (.clk(clkSelect), .reset, .SW(SW[1:0]), .pattern(LEDR[2:0]));
	
	// Show signals on LEDRs so we can see what is happening	
	assign LEDR[9] = clkSelect;
	assign LEDR[8] = reset;
		
endmodule	

module DE1_SoC_testbench();	
	 logic         CLOCK_50; 	
	 logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 		
	 logic  [9:0]  LEDR; 		
	 logic  [3:0]  KEY;
	 logic  [9:0]  SW; 
	
	DE1_SoC dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);	
		
	// Set up a simulated clock.	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		CLOCK_50 <= 0;	
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;	// Forever toggle the clock
	end	
		
	// Test the design.
	initial begin	
						 repeat(1) @(posedge CLOCK_50);	
		KEY[0] <= 0; repeat(1) @(posedge CLOCK_50); // press button = reset FSMs at start	
		KEY[0] <= 1; repeat(1) @(posedge CLOCK_50); // release button = run normally
		
		SW[1:0] <= 2'b00; repeat(6) @(posedge CLOCK_50); // calm wind
		SW[1:0] <= 2'b01; repeat(6) @(posedge CLOCK_50); // right to left
		SW[1:0] <= 2'b10; repeat(6) @(posedge CLOCK_50); // left to right
		
		$stop; // End the simulation.	
	end	
endmodule
