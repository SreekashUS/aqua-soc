`include "../arb/tdmArbiter.v"
`define COMPILE_CHECK
`define DUMMY
`include "../dummy/memory/memory.v"

`define FINISH
`define DUMP

module arbiterMemTb();
//Parameters arb/tdmArbiter START
	parameter ADDR_W=32;
	parameter IADDR_W=32;
	parameter DADDR_W=32;
	parameter DDATA_W=32;
//Parameters arb/tdmArbiter END

//Parameters dummy/memory START
	parameter MEM_ADDR_SIZE=32;
	parameter MEM_WORD_SIZE=32;
	parameter MEM_WR_LATENCY=2;
	parameter MEM_RD_LATENCY=2;
	parameter MEM_CLOCK_PERIOD_BY_2=5;
	parameter MEM_CLOCK_PERIOD=MEM_CLOCK_PERIOD_BY_2*2;
//Parameters dummy/memory END

//GlobalSignals START
	reg  clk=0;
	reg  reset=0;
//GlobalSignals END

//Module arb/tdmArbiter START
	//instruction port
	reg  [IADDR_W-1:0] memIAddr;
	reg  reqI;
	wire  memIReady;
	//data load/store port
	reg  [DADDR_W-1:0] memDAddr;
	reg  [DDATA_W-1:0] memDData;
	reg  wr;
	reg  reqD;
	wire  memDReady;

	//Memory interface signals
	//SignalsOverlap START
	wire memBusyOut;
	wire  [ADDR_W-1:0] memAddr;
	wire  memBusyIn;
	wire  memWr;
	wire  [DDATA_W-1:0] memDataIn;
	wire  [DDATA_W-1:0] memDataOut;
	//SignalsOverlap END
	wire  [DDATA_W-1:0] memDataOutReg;
	wire  memReq;
//Module arb/tdmArbiter END


//Module dummy/memory START
	//Signals are defined within arbiter
//Module dummy/memory END


//ModuleInstance dummy/memory START
	memory 
	#(
		/*Currently using 32 bits as WORD size 
		Later use 32-bit fetching from 8-bit word memory
		*/
		.MEM_WORD_SIZE(MEM_WORD_SIZE)
	)
	memory_inst
	(
		.*
	);
//ModuleInstance dummy/memory END


//ModuleInstance arb/tdmArbiter START
	tdmArbiter 
	#(

	)
	tdmArbiter_inst
	(
		.*
	);
//ModuleInstance arb/tdmArbiter END


//ClockGens START
	always #(MEM_CLOCK_PERIOD_BY_2) clk<=~clk;
//ClockGens END


	initial
	begin
		reset=1;
		#(MEM_CLOCK_PERIOD) reset =0;

		repeat(32)
		begin
			memIAddr=$random&4'hf;
			memDAddr=$random&4'hf;
			reqI=$random;
			reqD=$random;
			wr=$random;
			memDData=$random&8'hff;

			@(negedge memBusyOut);
			#(MEM_CLOCK_PERIOD);				
		end
`ifdef FINISH
		$finish;
`else
		$stop;
`endif
	end

`ifdef DUMP
	initial
	begin
		$dumpfile("dump.vcd");
		$dumpvars(0);
	end
`endif
endmodule