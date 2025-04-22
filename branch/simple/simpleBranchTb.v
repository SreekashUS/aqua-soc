
`define FINISH
`define DUMP

`include "simpleBranch.v"

module simpleBranchTb();

//GlobalParams START
	parameter CLK_PERIOD_BY_2=5;
	parameter CLK_PERIOD=CLK_PERIOD_BY_2*2;
//GlobalParams END

//Params simple/simpleBranch START;
	parameter  ADDR_SIZE=32;
	// Implement a mux for operations
	parameter  BRANCH_OPT=4;
//Params simple/simpleBranch END;


//Module simple/simpleBranch START
	reg  pcStall;
	reg  clk=0;
	reg  reset=0;
	reg  [1:0] selWire;
	reg  [ADDR_SIZE-1:0] jumpTarget1;
	reg  [ADDR_SIZE-1:0] jumpTarget2;
	reg  [ADDR_SIZE-1:0] jumpTarget3;
	wire  [ADDR_SIZE-1:0] pc;
//Module simple/simpleBranch END

//ModuleInstance simple/simpleBranch START
	simpleBranch
	#()
	simpleBranchInst
	(
		.*
	);
//ModuleInstance simple/simpleBranch END


//ClocksGen START
	always #(CLK_PERIOD_BY_2) clk<=~clk;
//ClocksGen END

	initial
	begin
		reset=1;
		#(CLK_PERIOD) reset=0;

		repeat(16)
		begin
			selWire=$random;
			pcStall=$random;
			jumpTarget1=$random;
			jumpTarget2=$random;
			jumpTarget3=$random;

			#(CLK_PERIOD);
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