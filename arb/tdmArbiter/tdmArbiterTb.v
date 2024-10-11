`define ADDR_W 32
`define IADDR_W `ADDR_W
`define DADDR_W `ADDR_W
`define DDATA_W 32

`include "tdmArbiter.v"

module tdmArbiterTb();

	parameter IADDR_W=`IADDR_W;
	parameter DADDR_W=`DADDR_W;
	parameter DDATA_W=`DDATA_W;
	parameter ADDR_W=`ADDR_W;

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
	
	//Clock and Reset
	reg  clk;
	reg  reset;

	//Stall on I/D requests
	wire memBusyOut
	//Memory interface
	wire [ADDR_W-1:0] memAddr;
	reg  memBusyIn;
	wire  memWr;
	wire [DDATA_W-1:0] memDataOut	//Sending to memory;
	reg  [DDATA_W-1:0] memDataIn		//Received from memory;


endmodule