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
`define ADDR_W 32
`define IADDR_W `ADDR_W
`define DADDR_W `ADDR_W
`define DDATA_W 32

module tdmArbiter
#(
	parameter IADDR_W=`IADDR_W
	,parameter DADDR_W=`DADDR_W
	,parameter DDATA_W=`DDATA_W
	,parameter ADDR_W=`ADDR_W
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
	,output wire memBusyOut
	//Memory interface
	,output reg [ADDR_W-1:0] memAddr
	,input wire memBusyIn
	,input wire memIdle
	,output reg memWr
	,input wire memReady
	,output reg [DDATA_W-1:0] memDataOut	//Sending to memory
	,input wire [DDATA_W-1:0] memDataIn		//Received from memory
);
	reg counter; //0-instruction,1-data

	assign memBusyOut=memBusyIn|~memIdle;

	always @(posedge clk,negedge reset)
	begin
		if(~reset)
			counter<=0;
		else
		begin
			if(~memBusyIn|memIdle)
			begin
				if(~counter && reqI)
				begin
					memAddr<=memIAddr;
				end
				else if(counter && reqD)
				begin
					memAddr<=memDAddr;
					memDataOut<=memDData;
					memWr<=wr;
				end
			end
		end
	end
endmodule

`endif //TDMARBITER_H