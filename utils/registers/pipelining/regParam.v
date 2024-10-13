`ifndef REGPARAM_H
`define REGPARAM_H

/*
normal registers without clock gating
*/

module regParam
#(
	parameter WIDTH=32
)
(
	input wire [WIDTH-1:0] regIn
	,input wire clk,reset
	,output reg regOut
);
	always @(posedge clk,posedge reset)
	begin
		if(reset)
			regOut<=0;
		else
			regOut<=regIn;
	end
endmodule

`endif //REGPARAM_H