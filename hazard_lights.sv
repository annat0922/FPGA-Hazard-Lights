module hazard_lights (clk, reset, SW, pattern);
	input logic clk, reset;
	input logic [1:0]SW;
	output logic [2:0]pattern;
	
	// state variables
	// A = 101, B= 010, C = 001, D = 100
	enum {A, B, C, D} ps, ns;
	
	always_comb begin
		case(ps)
			A: if (SW == 2'b00)		ns = B;
				else if (SW == 2'b01)		ns = C;
				else		ns = D;
			
			B: if (SW == 2'b00) 		ns = A;
				else if (SW == 2'b01) 		ns = D;
				else		ns = C;
			
			C: if (SW == 2'b00)		ns = A;
				else if (SW == 2'b01)		ns = B;
				else 		ns = D;
			
			D: if (SW == 2'b00)		ns = A;
				else if (SW == 2'b01)		ns = C;
				else		ns = B;
			
		endcase		
	end
	
	always_comb begin
		case (ps)
			A: pattern = 3'b101;
			B: pattern = 3'b010;
			C: pattern = 3'b001;
			D: pattern = 3'b100;
			default: pattern = 3'b000;
		endcase
	end
	
	// DFFs	
	always_ff @(posedge clk) begin	
		if (reset)	
			ps <= A;	
		else	
			ps <= ns;	
	end	
endmodule


module hazard_lights_testbench();	
	logic  clk, reset;
	logic [1:0]SW;
	logic [2:0]pattern;
	
	hazard_lights dut (.clk, .reset, .SW, .pattern);	
		
	// Set up a simulated clock.	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		clk <= 0;	
		forever #(CLOCK_PERIOD/2) clk <= ~clk;	// Forever toggle the clock
	end	
		
	// Set up the inputs to the design.  Each line is a clock cycle.	
	initial begin	
										 @(posedge clk);	
		reset <= 1;        		 @(posedge clk); // Always reset FSMs at start	
		reset <= 0; SW <= 2'b00; @(posedge clk);		
										 @(posedge clk);	
										 @(posedge clk);	
										 @(posedge clk);
										 @(posedge clk);	
										 @(posedge clk);
								  
		       SW <= 2'b01; 		 @(posedge clk);	
										 @(posedge clk);	
										 @(posedge clk);	
										 @(posedge clk);
										 @(posedge clk);	
										 @(posedge clk);
								  
				 SW <= 2'b10; 		 @(posedge clk);	
										 @(posedge clk);	
										 @(posedge clk);	
										 @(posedge clk);
										 @(posedge clk);	
										 @(posedge clk);
		$stop;
	end
endmodule
