//Simulation START
`timescale 1ns/1ps
`define DUMP
`define FINISH
//Simulation END

//DutSource START
`define DUMMY
`define COMPILE_CHECK
`include "memory.v"
//DutSource END

module memoryTb;

//Parameter dummy/memory START
	parameter MEM_ADDR_SIZE=32;
	parameter MEM_WORD_SIZE=8;
	parameter MEM_WR_LATENCY=2;
	parameter MEM_RD_LATENCY=2;
	parameter MEM_CLOCK_PERIOD_BY2=10;
	parameter MEM_CLOCK_PERIOD=MEM_CLOCK_PERIOD_BY2*2;
//Parameter dummy/memory END

//Module dummy/memory START
	reg  [MEM_ADDR_SIZE-1:0] memAddr;
	reg  [MEM_WORD_SIZE-1:0] memDataIn;
	reg  memWr;
	reg memReq=0;
	reg  clk=0;
	reg reset=0;
	wire  memBusyOut;
	wire [MEM_WORD_SIZE-1:0] memDataOut;
//Module dummy/memory START

//ModuleInst dummy/memory START
	memory memory_inst (.*);
//ModuleInst dummy/memory END

//SimControl START
	integer i;
	real delay;
	reg writePhase=1;
//SimControl END

//ClockGens START
	always #(MEM_CLOCK_PERIOD_BY2) clk<=~clk;
//ClockGens END


	always @(negedge clk)
	begin
		//request pulse
		memReq=writePhase? $random:1;
		#(MEM_CLOCK_PERIOD);
		memReq=0;
	end

	initial
	begin
		reset=1;
		#(MEM_CLOCK_PERIOD*2) reset=0;

		//Write randomized
		for(i=0;i<15;i=i+1)
		begin
			memAddr=i;
			memDataIn=$random;
			memWr=1;
			//Random write latencies
			// if($random)
			// 	#(`MEM_WR_LATENCY*(`MEM_CLOCK_PERIOD*0.5));
			// else
			// 	#(`MEM_WR_LATENCY*(`MEM_CLOCK_PERIOD*2));
			#(MEM_WR_LATENCY*(MEM_CLOCK_PERIOD));
		end
		memReq=0;
		writePhase=0;

`ifndef READ_RANDOM
		@(negedge memBusyOut);
`endif
		//Read randomized
		for(i=0;i<15;i=i+1)
		begin
			memAddr=i;
			memWr=0;
`ifdef READ_RANDOM
			#(MEM_RD_LATENCY*(MEM_CLOCK_PERIOD));
`else
			@(negedge memBusyOut);
`endif
		end
`ifdef FINISH
		$finish;
`else
		$stop;
`endif
	end

//DumpFileControl START
`ifdef DUMP
	initial
	begin
		$dumpfile("dump.vcd");
		$dumpvars(0);
	end
`endif
//DumpFileControl END

endmodule