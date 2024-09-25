`timescale 1ns/1ps

`define COMPILE_CHECK
`define MEM_CLOCK_PERIOD_BY2 5
`define MEM_CLOCK_PERIOD `MEM_CLOCK_PERIOD_BY2*2
`define IVERILOG

//Define memory access latencies
`define MEM_WR_LATENCY 5
`define MEM_RD_LATENCY 5

`include "memory.v"

module memoryTb;

	reg  [`MEM_ADDR_SIZE-1:0] memAddr;
	reg  [`MEM_WORD_SIZE-1:0] memDataIn;
	reg  wr;
	reg req=0;

	reg  clk=0;
	reg reset=0;

	wire  memBusy;
	wire [`MEM_WORD_SIZE-1:0] memDataOut;

	memory memory_inst(.*);

	always #`MEM_CLOCK_PERIOD_BY2 clk<=~clk;

	integer i;
	initial
	begin
		#1 reset=1;
		#10 reset=0;

		//Write randomized
		for(i=0;i<15;i=i+1)
		begin
			memAddr=i;
			memDataIn=$random;
			wr=1;

			//request pulse
			req=$random;
			#(`MEM_CLOCK_PERIOD);
			req=0;

			//Random read latencies
			if($random)
				#(`MEM_WR_LATENCY*(`MEM_CLOCK_PERIOD*0.5));
			else
				#(`MEM_WR_LATENCY*(`MEM_CLOCK_PERIOD*2));

		end
		req=0;

		//Read randomized
		for(i=0;i<15;i=i+1)
		begin
			memAddr=i;
			wr=0;

			//request pulse
			req=1;
			#(`MEM_CLOCK_PERIOD);
			req=0;

			#(`MEM_RD_LATENCY*(`MEM_CLOCK_PERIOD));
		end

		// #1000;
`ifdef IVERILOG
		$finish;
`else
		$stop;
`endif
	end


`ifdef IVERILOG
	initial
	begin
		$dumpfile("dump.vcd");
		$dumpvars(0);
	end
`endif
endmodule