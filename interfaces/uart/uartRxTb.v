`include "uartRx.v"
`include "uartTx.v"

`define FINISH
`define DUMP

//Turn on for checking parity errors
`define SIM_PARITY_ERRORS 
//Turn on for single parity errors
`define SIM_S_PARITY_ERRORS

/*
Testbench with uartTx and uartRx module connected to verify
on both sides data sent and data received are the same
*/

module uartRxTb();
//Parameters START
	parameter UART_CLOCK_PERIOD_BY_2=5;
	parameter UART_CLOCK_PERIOD=UART_CLOCK_PERIOD_BY_2*2;
	parameter CLOCK_DIV=54;
	parameter DATA_BITS=8;
	parameter STOP_BITS=1;
//Parameters END

//Module uart/uartTx START
	reg  [DATA_BITS-1:0] dataTx;
	reg startTx;
	wire uartBusyTx;
`ifdef SIM_PARITY_ERRORS
	wire uartTx;
`endif
//Module uart/uartTx END


//Module uart/uartRx START
	wire  uartReadyRx;
	wire  uartErrRx;
	wire  [DATA_BITS-1:0] dataRx;
`ifndef SIM_PARITY_ERRORS
	//SignalsOverlap START
	wire uart_tx_rx;
	//SignalsOverlap END
`else
	wire uartRx;
`endif
//Module uart/uartTxRx START

//GlobalSignals START
	reg clk=0;
	reg rst=0;
`ifdef SIM_PARITY_ERRORS
	reg parityErr=0;
`endif
//GlobalSignals END


//ModuleInstance uart/uartTx START
    uartTxMod
    #(
    	//config for parity/stop states baud rate etc
    )
    uartTxInst
    (
    	.*
    	//for direct testing
    	// ,.uartTx  (uart_tx_rx)
    );
//ModuleInstance uart/uartTx END

//ModuleInstance uart/uartRx START
    uartRxMod
    #(
    	//config for parity/stop states baud rate etc
    )
    uartRxInst
    (
    	.*
    	//for direct testing
    	// ,.uartRx(uart_tx_rx)
    );
//ModuleInstance uart/uartRx END

`ifdef SIM_PARITY_ERRORS
//GateInstance OR_parityError START
	assign uartRx=uartTx|parityErr;
//GateInstance OR_parityError END
`endif

//ClockGens START
	always #(UART_CLOCK_PERIOD_BY_2) clk<=~clk;
//ClockGens END


	initial
	begin
		rst=1;
		#(UART_CLOCK_PERIOD) rst=0;

		repeat(16)
		begin
			dataTx=$random;
			startTx=1;
			#(UART_CLOCK_PERIOD);
			startTx=0;

			@(negedge uartBusyTx);
			parityErr=0;

			#(UART_CLOCK_PERIOD*10);
		end

`ifdef FINISH
		$finish;
`else
		$stop;
`endif
	end

`ifdef SIM_PARITY_ERRORS
	//error insertion
	reg [1:0] parityErrFsm;
	localparam IDLE=0;
	localparam ERROR=1;
	localparam END=2;
	always @(posedge clk)
	begin
		case(parityErrFsm)
			IDLE:
			begin
				@(uartTxInst.bit_index);
				parityErrFsm<=ERROR;
			end
			ERROR:
			begin
				if(parityErr!=1)
				begin
					parityErr<=$random;
					@(uartTxInst.bit_index);
				end
				else
					parityErrFsm<=END;
			end
			END:
			begin
				parityErr<=0;
				@(uartTxInst.bit_index==0);
				parityErrFsm<=IDLE;
			end
			default:
				parityErrFsm<=IDLE;
		endcase
	end
`endif	

`ifdef DUMP
	initial
	begin
		$dumpfile("dump.vcd");
		$dumpvars(0);
	end
`endif

endmodule