`ifndef REGFILE2R1W_H
`define REGFILE2R1W_H

module regFile2R1W
#(
	parameter INT32W=32,
	parameter REGFILE_SIZE=5
) 
(
	//rs1 read
	input wire [REGFILE_SIZE-1:0] rs1,
	output reg [INT32W-1:0] dataRs1,
	//rs2 read
	input wire [REGFILE_SIZE-1:0] rs2,
	output reg [INT32W-1:0] dataRs2,
	//rd write
	input wire [REGFILE_SIZE-1:0] rd,
	input wire [INT32W-1:0] dataRd,
	
	// //WriteEnable (Redundant)
	// input wire we,
	
	//Clock
	input wire clk,
	//Reset
	input wire reset
);
	//x0 is 0 and cannot be written but read from

	/*
	Replace this part with SRAM for ASIC implementation
	and Replace this part with BlockRAm or BRAM for FPGA implementation
	*/
	reg [INT32W-1:0] registers [(1<<REGFILE_SIZE)-1:0];

	always @(posedge clk, negedge reset)
	begin
		if(~reset)
		begin
			//Use systemverilog for compiling
			for(integer i=0;i<32;i=i+1)
			begin
				registers[i]<=0;
			end
		end
		else
		begin
			if(rd!=0)
				registers[rd]<=dataRd;
			dataRs1<=registers[rs1];
			dataRs2<=registers[rs2];
		end
	end
endmodule

`endif //REGFILE2R1W_H