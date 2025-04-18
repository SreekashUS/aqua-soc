`ifndef SYNCFIFO_H
`define SYNCFIFO_H

module syncFifo
#(
	parameter DATA_BITS=8
	,FIFO_DEPTH_BITS=4
)
(
	input wire clk 						// Clock
	,input wire rst_n					// Asynchronous reset active low
	
	//Write
	,input wire we 						// write enable
	,input wire [DATA_BITS-1:0] dataIn	// write data
	,output wire wfull 					// write full

	//Read
	,input wire re 						// read enable
	,output reg [DATA_BITS-1:0] dataOut // read data
	,output wire rempty 				// read empty

	,output reg busy					//busy writing or reading to memory
);
	//FIFO depth based on depth bits
	parameter FIFO_DEPTH=(1<<FIFO_DEPTH_BITS);

	reg [FIFO_DEPTH_BITS:0] wptr;	//1-bit extra for wrap around logic
	reg [FIFO_DEPTH_BITS:0] rptr;	//1-bit extra for wrap around logic

	reg [DATA_BITS-1:0] fifoMem [FIFO_DEPTH-1:0];

	always @(posedge clk,negedge rst_n)
	begin
		if(~rst_n)
		begin
			wptr<=0;
			rptr<=0;
		end
		else
		begin
			if(we&(~wfull))
			begin
				fifoMem[wptr[FIFO_DEPTH_BITS-1:0]]=dataIn;
				wptr<=wptr+1;
			end
			if(re&(~rempty))
			begin
				dataOut=fifoMem[rptr[FIFO_DEPTH_BITS-1:0]];
				rptr<=rptr+1;
			end

			/*if both read and write are requested 
			priority is given to write*/
			busy<=re&we;
		end
	end

	assign rempty=(wptr==rptr);
	assign wfull=((wptr[FIFO_DEPTH_BITS-1:0]==rptr[FIFO_DEPTH_BITS-1:0])
				&(wptr[FIFO_DEPTH_BITS]!=rptr[FIFO_DEPTH_BITS]));

`ifdef FORMAL
	//Write formal checks
`endif

endmodule

`endif //SYNCFIFO_H