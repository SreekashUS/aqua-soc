`ifndef BAUD_GENERATOR_INT_H
`define BAUD_GENERATOR_INT_H

module baud_generator_int
#(
	parameter BAUD_BITS=16
)
(
	input wire clk //system clock
	,input wire nRst //reset
	,output wire baudClkTx //For TX clock
	,output reg baudClkRx //For RX sampling clock

	// config from uart interface
	,input wire [BAUD_BITS-1:0] baudDivisor //baud divisor bits in integer
	,input wire baudOversampling
);
	reg [BAUD_BITS-1:0] rxCounter;
	//usually oversampling for 8x, 16x but keeping this as full value for 
	reg [(1<<4)-1:0] txCounter;

	//counter for Rx
	always @(posedge clk, negedge nRst)
	begin
		if(~nRst)
		begin
			rxCounter<=0;
			baudClkRx<=0;
		end
		else
          if(rxCounter<(baudDivisor/2)-1)
				rxCounter<=rxCounter+1;
			else
			begin
				rxCounter<=0;
				baudClkRx<=~baudClkRx;
			end
	end

	always @(posedge baudClkRx,negedge nRst)
	begin
		if(~nRst)
			txCounter<=0;
		else
			txCounter<=txCounter+1;
	end

	wire baud_clk_mult;
  assign baud_clk_mult=txCounter[baudOversampling+2];
	assign baudClkTx=baud_clk_mult;
endmodule

`endif //BAUD_GENERATOR_INT_H