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
	reg requestSent;

	always @(posedge clk,posedge reset)
	begin
		if(reset)
		begin
			counter<=0;
			requestSent<=0;			
		end
		else
		begin
			if(~memBusyOut)
			begin
				if(~counter && reqI)
				begin
					memAddr<=memIAddr;
					memWr<=0;
					requestSent<=1;
				end
				else if(counter && reqD)
				begin
					memAddr<=memDAddr;
					memDataIn<=memDData;
					memWr<=wr;
					requestSent<=1;
				end
				memReq<=1;
				counter<=~counter;
			end
			else
			begin
				if(requestSent)
				begin
					if(~memBusyOut)
					begin
						if(counter)
						begin
							memDReady<=1;
							memIReady<=0;
						end
						else
						begin
							memIReady<=1;
							memDReady<=0;
						end
						requestSent<=0;
						memDataOutReg<=memDataOut;
						memReq<=0;
					end
				end
			end
		end
	end
endmodule

`endif //TDMARBITER_H