`include "aluRv32i.v"

`define UNIT_TEST
`define DUMP
`define GTKWAVE

module aluRv32i_Tb();

	reg  [`INT32W-1:0] 	input1In;
	reg  [`INT32W-1:0] 	input2In;
	reg  [`OPW-1:0]		opType;
	wire [`INT32W-1:0]	resultOut;

	wire [4:0] shft=input2In[4:0];

// Instance START
	aluRv32i
	// #(
	// )
	alu_inst
	(
		.*
	);
// Instance END

	initial
	begin
		repeat(32)
		begin
			opType<=$random & 4'b0011;	//For Add/Logical Etc
			// opType<=$random & 4'b0011;	//For shifts
			input1In<=$random % 11;
			input2In<=$random % 17;
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