`define DUMMY
`define FINISH
`define DUMP

`include "byteMemory.v"


module byteMemoryTb();

//Parameters byteMemory/memBank START
	parameter MEM_BANK_BITS=2;
	parameter MEM_BANKS=(1<<MEM_BANK_BITS);
	parameter MEM_BANK_ADDR_SIZE_FULL=32;
	parameter MEM_BANK_BANK_WORD_SIZE=8;
	parameter MEM_BANK_WR_LATENCY=2;
	parameter MEM_BANK_RD_LATENCY=2;
	parameter MEM_BANK_CLOCK_PERIOD_BY_2=5;
	parameter MEM_BANK_CLOCK_PERIOD=MEM_BANK_CLOCK_PERIOD_BY_2*2;
//Parameters byteMemory/memBank END

//Parameters byteMemory/byteMemory START
	parameter MEM_ADDR_SIZE=32;
	parameter MEM_STROBE_BITS=4;
	parameter BURST_BITS=2;
	parameter MEM_WORD_SIZE=32;
	parameter MEM_BANK_ADDR_SIZE=MEM_ADDR_SIZE-MEM_BANK_BITS;
//Parameters byteMemory/byteMemory END

//GlobalSignals START
	reg  clk=0;
	reg  reset=0;
//GlobalSignals END

//Module byteMemory/byteMemory START
	reg  [MEM_ADDR_SIZE-1:0] memAddr;
	reg  [MEM_WORD_SIZE-1:0] memDataIn;
	reg  [MEM_STROBE_BITS-1:0] memStrb;
	reg  memWr;
	reg  [BURST_BITS-1:0] memBurstLen;
	wire  memBusyOut;
	wire [MEM_WORD_SIZE-1:0] memDataOut;
//Module byteMemory/byteMemory END

//ModuleInstance byteMemory/byteMemory START
	byteMemory
	#()
	byteMemoryInst
	(
		.*
	);
//ModuleInstance byteMemory/byteMemory END

//ClocksGens START
	always #(MEM_BANK_CLOCK_PERIOD_BY_2) clk<=~clk;
//ClocksGens END


	initial
	begin
		reset=1;
		#(MEM_BANK_CLOCK_PERIOD) reset=0;
		
//Phase Write START
		memAddr=0;
		memDataIn=$random;
		repeat(8)
		begin
			//Write to all strobe lines?
			memStrb=~0;
			memWr=1;
			memBurstLen=0;

			@(negedge memBusyOut);
			memAddr=memAddr+4;
			memDataIn=$random;
			#(MEM_BANK_CLOCK_PERIOD);
		end
//Phase Write END

//Phase Read START
		memAddr=0;
		repeat(8)
		begin
			memDataIn=$random;
			//Read from random strobe lines
			memStrb=~0;
			memWr=0;
			memBurstLen=0;

			@(negedge memBusyOut);
			memAddr=memAddr+4;
			#(MEM_BANK_CLOCK_PERIOD);
		end
//Phase Read END




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