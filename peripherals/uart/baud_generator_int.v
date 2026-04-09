`ifndef BAUD_GENERATOR_INT_H
`define BAUD_GENERATOR_INT_H

module baud_generator_int
#(
	parameter BAUD_BITS=16
)
(
	input wire sysClk //system clock
	,input wire nRst //reset
	,output reg baudClkTx //For TX clock
	,output reg baudClkRx //For RX sampling clock

	// config from uart interface
	,input wire [BAUD_BITS-1:0] baudDivisor //baud divisor bits in integer
	,input wire [1:0] baudOversampling //0-1x,1-4x,2-8x,3-16x
);
	reg [BAUD_BITS-1:0] rxCounter;
	//usually oversampling for 8x, 16x but keeping this as full value for 
	reg [BAUD_BITS-1:0] txCounter;

	//counter for Rx
	always @(posedge sysClk, negedge nRst)
	begin
		if(nRst)
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
		if(nRst)
		begin
			baudClkTx<=0;
			txCounter<=0;
		end
		else
		begin
			if(txCounter<(1<<(baudOversampling+1))-1)
				txCounter<=txCounter+1;
			else
			begin
				txCounter<=0;
				baudClkTx<=~baudClkTx;
			end
		end
	end
endmodule

`endif //BAUD_GENERATOR_INT_H