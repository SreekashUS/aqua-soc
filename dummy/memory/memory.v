`ifndef MEMORY_H
`define MEMORY_H

/*
Dummy memory module with parametrizable read/write latencies and ports
*/
//define this if dummy model is used
`ifdef DUMMY

	`define COMPILE_CHECK
	`ifdef COMPILE_CHECK
		`define SIM
		`define USE_MEM_LATENCY
	`endif

module memory 
#(
	parameter MEM_ADDR_SIZE=32
	,parameter MEM_WORD_SIZE=8
	,parameter MEM_WR_LATENCY=2
	,parameter MEM_RD_LATENCY=2
	,parameter MEM_CLOCK_PERIOD=10
)
(
	//memory request side
	input wire [MEM_ADDR_SIZE-1:0] memAddr
	,input wire [MEM_WORD_SIZE-1:0] memDataIn
	,input wire memWr
	,input wire memReq
	//global signals for memory and requester
	,input wire clk,reset
	//status signals and output data for memory
	,output reg memBusyOut
	,output reg [MEM_WORD_SIZE-1:0] memDataOut
);
	//simulation purposes,
	//otherwise connect to external modules (BRAM, physical DRAM etc)
	`ifdef SIM
		reg [MEM_WORD_SIZE-1:0] memory [MEM_ADDR_SIZE-1:0];
	`endif
	//state machine model
	reg [1:0] memState;
	//states
	localparam MEM_IDLE=0;
	localparam MEM_BUSY=1;
	localparam MEM_READY=2;

	always @(posedge clk,posedge reset)
	begin
		if(reset)
		begin
			memBusyOut=0;
			memDataOut=0;
			memState=MEM_IDLE;
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
`endif //DUMMY

`endif //MEMORY_H