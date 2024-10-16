`ifndef TDMARBITER_H
`define TDMARBITER_H

/*
Basic arbiter used for time multiplexing the requests
Data size is 32 bits for both cases
Add functionality for Loading/Storing Byte,Half-Word,Word,Double-Word in another module
	- Cause this can be useful in cache accesses

TODO: Need to add Memory Management Unit (MMU) later that deals with virtual memory addresses
Need to simplify ports
*/

module tdmArbiter
#(
	parameter IADDR_W=32
	,parameter DADDR_W=32
	,parameter DDATA_W=32
	,parameter ADDR_W=32
) 
(
	//instruction port
	input wire [IADDR_W-1:0] memIAddr
	,input wire reqI
	,output reg memIReady
	//data load/store port
	,input wire [DADDR_W-1:0] memDAddr
	,input wire [DDATA_W-1:0] memDData
	,input wire wr
	,input wire reqD
	,output reg memDReady
	//Clock and Reset
	,input wire clk
	,input wire reset
	
	//Stall on I/D requests
	,input wire memBusyOut
	//Memory interface
	,output reg [ADDR_W-1:0] memAddr
	,output reg memWr
	,output reg memReq
	,output reg [DDATA_W-1:0] memDataIn		//Sending to memory
	,input wire [DDATA_W-1:0] memDataOut	//Received from memory
	,output reg [DDATA_W-1:0] memDataOutReg	//received data buffer
);
	//0-instruction,1-data
	reg counter;

	localparam ARB_IDLE		=0;
	localparam ARB_REQUEST	=1;
	localparam ARB_STABLE	=2;
	localparam ARB_DONE		=3;

	reg [1:0] arbState;

	always @(posedge clk,posedge reset)
	begin
		if(reset)
		begin
			counter<=0;
			memReq<=0;
			memIReady<=0;
			memDReady<=0;
			arbState<=ARB_IDLE;
		end
		else
		begin
			case(arbState)
				ARB_IDLE:
				begin
					if(counter==0 && reqI)
					begin
						memAddr<=memIAddr;
						memWr<=0;
						memReq<=1;
						memIReady<=0;
						arbState<=ARB_REQUEST;
					end
					else if(counter==1 && reqD)
					begin
						memAddr<=memDAddr;
						memWr<=wr;
						memDataIn<=memDData;
						memReq<=1;
						memDReady<=0;
						arbState<=ARB_REQUEST;
					end
					// wait for requests continuously
					else
					begin
						counter<=~counter;
					end
				end

				ARB_REQUEST:
				begin
					memReq<=0;
					arbState<=ARB_STABLE;
				end

				ARB_STABLE:
				begin
					//Keep arbiter in this mode until request completes
					if(~memBusyOut)
					begin
						arbState<=ARB_DONE;
						memIReady<=(counter==0);
						memDReady<=(counter==1);
					end
				end

				ARB_DONE:
				begin
					memDataOutReg<=memDataOut;
					counter<=~counter;
					arbState<=ARB_IDLE;
					memIReady<=0;
					memDReady<=0;
				end
			endcase
		end
	end
endmodule

`endif //TDMARBITER_H