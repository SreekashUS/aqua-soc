`ifndef SIMPLEBRANCH_H
`define SIMPLEBRANCH_H

module simpleBranch
#(
	parameter ADDR_SIZE=32
	// Implement a mux for operations
	,parameter BRANCH_OPT=4
)
(
	//PC stall wire -  stalls update of PC for Hazards
	input wire pcStall
	,input wire clk,reset
	/*
	Target selection
	done after branch resolution,or normal instruction operation
	*/
	,input wire [1:0] selWire

	/*
	Jump targets can be configured based on future modules that
	can use branch prediction, feedback paths etc
	*/
	,input wire [ADDR_SIZE-1:0] jumpTarget1
	,input wire [ADDR_SIZE-1:0] jumpTarget2
	,input wire [ADDR_SIZE-1:0] jumpTarget3

	,output reg [ADDR_SIZE-1:0] pc
);
	/*
	PC can be set using LUI and ADDI to any instruction in the 32-bit address space
	But limited to 1 Mb(20 bits) in this case
	*/

	always @(posedge clk,posedge reset)
	begin
		if(reset)
			pc<=0;
		else
		begin
			if(~pcStall)
			begin
				case(selWire)
					2'd0:
						pc<=pc+4;
					2'd1:
						pc<=jumpTarget1;
					2'd2:
						pc<=jumpTarget2;
					2'd3:
						pc<=jumpTarget3;
					default:
						pc<=pc+4;
				endcase
			end
		end
	end

endmodule

`endif //SIMPLEBRANCH_H