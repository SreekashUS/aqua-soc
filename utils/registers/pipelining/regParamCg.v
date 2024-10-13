`ifndef REGPARAMCG_H
`define REGPARAMCG_H

/*
Pipelined registers with feature of clock gating
or clock enable for stalling the flow
*/

module regParamCg
#(
	//register width
	parameter WIDTH=8
)
(
	input wire [WIDTH-1:0] regIn
	,input wire clk,reset
	,input wire en
	,output reg [WIDTH-1:0] regOut
);
	always @(posedge clk,posedge reset)
	begin
		if(reset)
			regOut<=0;
		else if(en)
			regOut<=regIn;
	end
endmodule 

`endif //REGPARAMCG_H