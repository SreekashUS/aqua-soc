`ifndef BAUD_GENERATORS_H
`define BAUD_GENERATORS_H

module BaudGeneratorInt
#(
	parameter BAUD_BITS=16
)
(
	input wire clk,rst,
	input wire [BAUD_BITS-1:0] divisor,
	output reg baud_clk
);
	reg [BAUD_BITS-1:0] counter;

	always @(posedge clk, posedge rst)
	begin
		if(rst)
		begin
			counter<=0;
			baud_clk<=0;
		end
		else
			if(counter<(divisor/2)-1)
				counter<=counter+1;
			else
			begin
				counter<=0;
				baud_clk<=~baud_clk;
			end
	end
endmodule

`endif //BAUD_GENERATORS_H