`include "regFile2R1W.v"

`define UNIT_TEST
`define DUMP
`define GTKWAVE

module regFile2R1W_Tb();

	reg  [`REGFILE_SIZE-1:0] 	rs1;
	wire  [`INT32W-1:0] 	dataRs1;
	reg  [`REGFILE_SIZE-1:0] 	rs2;
	wire  [`INT32W-1:0] 	dataRs2;

	reg  [`REGFILE_SIZE-1:0] 	rd;
	reg  [`INT32W-1:0] 	dataRd;

	reg clk=0;
	reg rst=1;

	always #5 clk<=~clk;

// Instance START
	regFile2R1W
	// #(
	// )
	regFile2R1W_inst
	(
		.*
	);
// Instance END

	initial
	begin
		rst=0;
		#5
		rst=1;

		repeat(512)
		begin
			rs1<=$random;
			rs2<=$random;
			rd <=$random;		//Check for data hazards later
			dataRd<=$random;
			#1;
		end

//Stop simulation if unit test
`ifdef UNIT_TEST
	`ifdef GTKWAVE
		$finish();
	`else
		$stop();
	`endif
`endif
	end

//perform functional checks here
	// always @(*)
	// begin

	// end

`ifdef DUMP
	initial
	begin
		$dumpfile("dump.vcd");
		$dumpvars(0);
	end
`endif
endmodule