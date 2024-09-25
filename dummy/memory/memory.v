// `define COMPILE_CHECK

`ifdef COMPILE_CHECK
	`define DUMMY
	`define SIM
	`define USE_MEM_LATENCY
`endif

`ifdef DUMMY

	`ifndef MEMORY_H
	`define MEMORY_H

	`ifndef MEM_ADDR_SIZE
		`define MEM_ADDR_SIZE 32
	`endif

	`ifndef MEM_WORD_SIZE
		`define MEM_WORD_SIZE 8
	`endif

	`ifndef MEM_CLOCK_PERIOD
		`define MEM_CLOCK_PERIOD 10		//default sim time unit - 1ns
	`endif

	`ifndef MEM_WR_LATENCY
		`define MEM_WR_LATENCY 10
	`endif

	`ifndef MEM_RD_LATENCY
		`define MEM_RD_LATENCY 10
	`endif

module memory 
#(
	parameter ADDR_W=`MEM_ADDR_SIZE
	,parameter DATA_W=`MEM_WORD_SIZE
	//10 units default
	,parameter MEM_WR_LATENCY=`MEM_WR_LATENCY
	,parameter MEM_RD_LATENCY=`MEM_RD_LATENCY
	//Override from simulation macro file
	,parameter MEM_CLOCK_PERIOD=`MEM_CLOCK_PERIOD
)
(
	input wire [ADDR_W-1:0] memAddr
	,input wire [DATA_W-1:0] memDataIn
	,input wire wr
	,input wire req

	,input wire clk,reset

	,output reg memBusy
	,output reg [DATA_W-1:0] memDataOut
);

	`ifdef SIM
	reg [DATA_W-1:0] memory [ADDR_W-1:0];
	`endif

	always @(posedge clk,posedge reset)
	begin
		if(reset)
		begin
			memBusy=0;
			memDataOut=0;
		end
		else
		begin
			if(~memBusy && req)
			begin
				if(wr)
				begin
					memory[memAddr]=memDataIn;
					memBusy=1;
				`ifdef USE_MEM_LATENCY
					#(MEM_WR_LATENCY*`MEM_CLOCK_PERIOD);
				`endif
					memBusy=0;
				end
				else
				begin
					memDataOut=memory[memAddr];
					memBusy=1;
				`ifdef USE_MEM_LATENCY
					#(MEM_RD_LATENCY*`MEM_CLOCK_PERIOD);
				`endif
					memBusy=0;
				end
			end
		end
	end
endmodule
	`endif //MEMORY_H

`endif //DUMMY