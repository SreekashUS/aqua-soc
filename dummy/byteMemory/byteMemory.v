`ifndef BYTEMEMORY_H
`define BYTEMEMORY_H

`define DUMMY

`ifdef DUMMY

	`define COMPILE_CHECK
	`ifdef COMPILE_CHECK
		`define SIM
		`define USE_MEM_LATENCY
	`endif

module memBank
#(
	parameter MEM_BANK_BITS=2
	,parameter MEM_BANKS=(1<<MEM_BANK_BITS)
	,parameter MEM_ADDR_SIZE_FULL=32
	,parameter MEM_ADDR_SIZE=MEM_ADDR_SIZE_FULL-MEM_BANK_BITS
	,parameter MEM_WORD_SIZE=8
	,parameter MEM_WR_LATENCY=2
	,parameter MEM_RD_LATENCY=2
	,parameter MEM_CLOCK_PERIOD=10
)
(
	//mem Request
	input wire [MEM_ADDR_SIZE-1:0] memAddr
	,input wire [MEM_WORD_SIZE-1:0] memDataIn
	,input wire memWr
	,input wire memReq
	//global signals
	,input wire clk,reset
	//status signals and output data
	,output reg memBusyOut
	,output reg [MEM_WORD_SIZE-1:0] memDataOut
);

	`ifdef SIM
		reg [MEM_WORD_SIZE-1:0] memory [MEM_ADDR_SIZE-1:0];
	`endif	

	reg [1:0] memState;

	localparam MEM_IDLE=0;
	localparam MEM_BUSY=1;
	localparam MEM_READY=2;

	always @(posedge clk, posedge reset)
	begin
		if(reset)
		begin
			
		end
		else
		begin
			case(memState)
				MEM_IDLE:
				begin
					if(memReq)
					begin
						memState=MEM_BUSY;
						memBusyOut=1;
					end
				end
				MEM_BUSY:
				begin
					if(memWr)
					begin
						memory[memAddr]=memDataIn;
						`ifdef USE_MEM_LATENCY
							#(MEM_WR_LATENCY*MEM_CLOCK_PERIOD);
						`endif
					end
					else
					begin
						`ifdef USE_MEM_LATENCY
							#(MEM_RD_LATENCY*MEM_CLOCK_PERIOD);
						`endif	
						memDataOut=memory[memAddr];
					end
					memBusyOut=0;
					memState=MEM_READY;
				end
				MEM_READY:
				begin
					memState=MEM_IDLE;
				end
				default:
					memState=MEM_IDLE;
			endcase
		end
	end
endmodule


module byteMemory
#(
	parameter MEM_ADDR_SIZE=32
	,parameter MEM_STROBE_BITS=4
	,parameter BURST_BITS=2
	,parameter MEM_WORD_SIZE=32
	,parameter MEM_WR_LATENCY=2
	,parameter MEM_RD_LATENCY=2
	,parameter MEM_CLOCK_PERIOD=10
)
(
	input wire [MEM_ADDR_SIZE-1:0] memAddr
	,input wire [MEM_WORD_SIZE-1:0] memDataIn
	,input wire [MEM_STROBE_BITS-1:0] memStrb
	,input wire memWr
	,input wire clk,reset
	//burst length 
	,input wire [BURST_BITS-1:0] memBurstLen
	,output reg memBusyOut
	,output reg [MEM_WORD_SIZE-1:0] memDataOut
);

	//TODO

endmodule


`endif

`endif //BYTEMEMORY_H