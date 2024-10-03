`timescale 1ns/1ps

//define UART config here


`include "uartTx.v"

`define FINISH
`define DUMP

module uartTb();

//Parameters START
	parameter UART_CLOCK_PERIOD_BY_2=5;
	parameter UART_CLOCK_PERIOD=UART_CLOCK_PERIOD_BY_2*2;
	parameter CLOCK_DIV=434;
    parameter DATA_BITS=8;
    parameter STOP_BITS=1;
//Parameters END


//GlobalSignals START
    reg  clk=0;
    reg  rst=0;
    reg  startTx;
    reg  [DATA_BITS-1:0] dataTx;
    wire uartTx;
    wire uartBusyTx;
//GlobalSignals END

//ModuleInstance uart/uartTx START
    uartTxMod
    #(
    	//config for parity/stop states baud rate etc
    )
    uartTxInst
    (
    	.*
    );
//ModuleInstance uart/uartTx END

//ClockGens START
	always #(UART_CLOCK_PERIOD_BY_2) clk<=~clk;
//ClockGens END

	initial
	begin
		rst=1;
		startTx=0;
		
		#(UART_CLOCK_PERIOD) rst=0;
		repeat(16)
		begin
			// dataTx=8'hff;
			dataTx=$random;
			startTx=1;
			#(UART_CLOCK_PERIOD);
			startTx=0;

			@(negedge uartBusyTx);

			#(UART_CLOCK_PERIOD*10);
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