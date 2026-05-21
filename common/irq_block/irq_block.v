`ifndef IRQ_BLOCK_H
`define IRQ_BLOCK_H

module irq_block
#(
	parameter WIDTH=8
)
(
	input wire clk
	,input wire nRst
	,input wire [WIDTH-1:0] events
	,input wire [WIDTH-1:0] mask
	,input wire [WIDTH-1:0] clear

	,output reg [WIDTH-1:0] pending
	,output wire irq
);
	always @(posedge clk,negedge nRst)
	begin
		if(~nRst)
		begin
          pending<=0;
		end
		else
		begin
          pending<=(~clear)&(pending|(mask&events));
		end
	end

  assign irq=|pending;
endmodule

`endif //IRQ_BLOCK_H