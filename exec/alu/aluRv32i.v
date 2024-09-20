`ifndef ALURV32I_H
`define ALURV32I_H

/*
intMain unit:
	- performs arithmetic operations (from register file and immediates)
	- performs logical operations
	- performs shift operations
	- behaves as Address Generation Unit(AGU) for LSU(Load-Store unit in the memory stage)
	- no overflow or special checks are implemented(TODO) 

Note:
1.What instructions need this unit for calculation
	- ADDI/SLTI[U]{Need to study this==Using sub to determine/using < operator}
	- ANDI/ORI/XORI
	- SLLI/SRLI/SRAI (shifts)
	- ADD/SLT[U]
	- AND/OR/XOR
	- SLL/SRL
	- SUB/SRA
	- LUI/AUIPC
	Address Generation Unit based:
	- JAL/JALR
	- BEQ/BNE/BLT[U]/BGE[U]
	- (Load/Store)[B H U BU HU]
2. Immediates are loaded into operand 2 port(usually from rs2)
3. opType is used to perform ALU operation required, necessary instructions
	can be translated to ALU operations
*/

//Can extend the ALU bit width from external configurations
`ifndef INT32W
	`define INT32W 32
`endif

`define OPW 4

module aluRv32i
#(
	parameter INT32W=`INT32W
)
(	
	//bind to rs1 usually
	input wire [INT32W-1:0] 	input1In
	//bind to imm or rs2
	,input wire [INT32W-1:0] 	input2In
	//decoded at the decode stage 
	,input wire [`OPW-1:0]		opType
	//result
	,output reg [INT32W-1:0]	resultOut
);
	//opTypes
	localparam ADD_TYPE=4'd0;
	localparam AND_TYPE=4'd1;
	localparam ORR_TYPE=4'd2;
	localparam XOR_TYPE=4'd3;
	localparam SLL_TYPE=4'd4;
	localparam SRL_TYPE=4'd5;
	localparam SRA_TYPE=4'd6;
	localparam SLT_TYPE=4'd7;
	localparam SLU_TYPE=4'd8;

	//For signed operations
	wire signed [INT32W-1:0] input2InSigned;
	wire signed [INT32W-1:0] input1InSigned;
	assign input1InSigned=input1In;
	assign input2InSigned=input2In;

	always @(*)
	begin
		case(opType)
			ADD_TYPE:
				resultOut=input1In+input2In;
			AND_TYPE:
				resultOut=input1In&input2In;
			ORR_TYPE:
				resultOut=input1In|input2In;
			XOR_TYPE:
				resultOut=input1In^input2In;
			//shift left(logical)
			SLL_TYPE:
				resultOut=input1In<<input2In[4:0];
			//shift right(logical)
			SRL_TYPE:
				resultOut=input1In>>input2In[4:0];
			//shift right(arithmetic)
			SRA_TYPE:
				resultOut=input1InSigned>>>input2In;
			//Set less than(signed)
			SLT_TYPE:
				resultOut=input1InSigned<input2InSigned;
			//Set less than(unsigned)
			SLU_TYPE:
				resultOut=input1In<input2In;
			default:
				resultOut=0;
		endcase
	end
endmodule

`endif //ALURV32I_H