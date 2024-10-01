`timescale 1ns/1ps

//define UART config here


`include "uartTx.v"

`define FINISH
`define DUMP

module uartTb();

//Parameters START
	parameter MEM_CLOCK_PERIOD_BY_2=5;
	parameter MEM_CLOCK_PERIOD=MEM_CLOCK_PERIOD_BY_2*2;
	parameter CLOCK_DIV=434;
    parameter DATA_BITS=8;
    parameter STOP_BITS=1;
//Parameters END


//GlobalSignals START
    reg  clk=0;
    reg  rst=0;
    reg  start;
    reg  [DATA_BITS-1:0] data;
    wire uart_tx;
    wire busy;
//GlobalSignals END

//ModuleInstance uart/uartTx START
    uartTx
    #(
    	//config for parity/stop states baud rate etc
    )
    uartTxInst
    (
    	.*
    );
//ModuleInstance uart/uartTx END

//ClockGens START
	always #(MEM_CLOCK_PERIOD_BY_2) clk<=~clk;
//ClockGens END

	initial
	begin
		rst=1;
		start=0;
		
		#(MEM_CLOCK_PERIOD) rst=0;
		repeat(16)
		begin
			// data=8'hff;
			data=$random;
			start=1;
			#(MEM_CLOCK_PERIOD);
			start=0;

			@(negedge busy);

			#(MEM_CLOCK_PERIOD*10);
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