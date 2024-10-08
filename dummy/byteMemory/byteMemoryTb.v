`include "byteMemory.v"

`define DUMMY

byteMemoryTb();

//Parameters byteMemory/memBank START
	parameter MEM_BANK_BITS=2;
	parameter MEM_BANKS=(1<<MEM_BANK_BITS);
	parameter MEM_BANK_ADDR_SIZE_FULL=32;
	parameter MEM_BANK_BANK_WORD_SIZE=8;
	parameter MEM_BANK_WR_LATENCY=2;
	parameter MEM_BANK_RD_LATENCY=2;
	parameter MEM_BANK_CLOCK_PERIOD=10;
//Parameters byteMemory/memBank END

//Parameters byteMemory/byteMemory START
	parameter MEM_ADDR_SIZE=32;
	parameter MEM_STROBE_BITS=4;
	parameter BURST_BITS=2;
	parameter MEM_WORD_SIZE=32;
	parameter MEM_BANK_ADDR_SIZE=MEM_ADDR_SIZE-MEM_BANK_BITS;
//Parameters byteMemory/byteMemory END



endmodule