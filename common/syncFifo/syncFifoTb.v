`include "syncFifo.v"

`define FINISH
`define DUMP

/*
Testbench with uartTx and uartRx module connected to verify
on both sides data sent and data received are the same
*/

module syncFifoTb();

//Parameters START
	parameter CLK_PERIOD_BY_2=5;
	parameter CLK_PERIOD=(CLK_PERIOD_BY_2<<1);
	parameter DATA_BITS=8;
	parameter FIFO_DEPTH_BITS=3;
//Parameters END

//Module syncFifo/syncFifo START
	reg we=0;
	reg [DATA_BITS-1:0] dataIn;
	wire wfull;

	reg re=0;
	wire [DATA_BITS-1:0] dataOut;
	wire rempty;

	wire busy;
//Module syncFifo/syncFifo END

//GlobalSignals START
	reg clk=0;
	reg rst_n=1;
//GlobalSignals END

//ModuleInstance uart/uartTx START
    syncFifo
    #(
    	.DATA_BITS      (DATA_BITS)
    	,.FIFO_DEPTH_BITS(FIFO_DEPTH_BITS)
    )
    syncFifoInst
    (
    	.*
    );
//ModuleInstance uart/uartTx END


//ClockGens START
	always #(CLK_PERIOD_BY_2) clk<=~clk;
//ClockGens END

	initial
	begin
		// dataIn=$random;
		rst_n=0;
		#(CLK_PERIOD) rst_n=1;

		repeat(10)
		begin
			if(!wfull)
			begin
				dataIn<=$random;
				we<=1;
			end
			@(posedge clk);
		end
		we<=0;

		repeat(10)
		begin
			if(!rempty)
			begin
				re<=1;
			end
			@(posedge clk);
		end

		repeat(1)
		begin
			we<=1;
			re<=1;
			dataIn<=$random;
			@(posedge clk);
		end
		re<=0;

		repeat(10)
		begin
			if(!wfull)
			begin
				dataIn<=$random;
				we<=1;
			end
			@(posedge clk);
		end
		we<=0;

		repeat(10)
		begin
			if(!rempty)
			begin
				re<=1;
			end
			@(posedge clk);
		end

		#(CLK_PERIOD*10);

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