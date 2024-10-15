/*
# RV32I unprivileged base ISA
---

`Note`: Just a decoder unit, complete microarchitecture written somewhere else
*/

`ifndef RV32IDECODER_H
`define RV32IDECODER_H

module rv32iDecoder
#(
	parameter REG_COUNT=5
	,parameter XLEN=32
)
(
	//Input instruction
	input wire [XLEN-1:0] 			instrIn

	//registers and Types
	,output wire [REG_COUNT-1:0]	rs1
	,output wire [REG_COUNT-1:0]	rs2
	//immediates,rd and shamt decoded in the subsequent stages to reduce pipeline FFs
	,output wire [24:0]				immsRdShamt

	//Instruction type
	,output wire 					isLoad
	,output wire 					isStore
	,output wire 					isMemOrder
	,output wire 					isAluReg
	,output wire 					isAluImm
	,output wire 					isLui
	,output wire 					isAuipc
	,output wire					isJAL
	,output wire					isJALR
	,output wire					isBranch
	,output wire					isSysCall
);

	//Opcodes unpriv RV32I-20240411 documentation
	//removed lower bits as all are 2'b11 at instrIn[1:0]
	localparam Load_Opcode		=5'b00000;
	localparam Store_Opcode		=5'b01000;
	localparam MemOrder_Opcode	=5'b00011;
	localparam AluReg_Opcode	=5'b01100;
	localparam AluImm_Opcode	=5'b00100;
	localparam Lui_Opcode 		=5'b01101;
	localparam Auipc_Opcode		=5'b00101;
	localparam Jal_Opcode		=5'b11011;
	localparam Jalr_Opcode		=5'b11001;
	localparam Branch_Opcode	=5'b11000;
	localparam SysCall_Opcode	=5'b11100;

	//registers (r-type instructions)
	assign rs1		=instrIn[19:15];
	assign rs2		=instrIn[24:20];

	/*
	decoder redesign
	- immediate extraction is performed in later stages
	in order to reduce the pipeline width
	- and to probably support the 2R1W cycles, considering
	only 2 reads/writes can be supported concurrently
	*/
	assign immsRdShamt=instrIn[31:7];
	//type of instruction
	assign isLoad		= (instrIn[6:2]==Load_Opcode);
	assign isStore		= (instrIn[6:2]==Store_Opcode);
	assign isMemOrder	= (instrIn[6:2]==MemOrder_Opcode);
	assign isAluReg		= (instrIn[6:2]==AluReg_Opcode);
	assign isAluImm		= (instrIn[6:2]==AluImm_Opcode);
	assign isLui		= (instrIn[6:2]==Lui_Opcode);
	assign isAuipc		= (instrIn[6:2]==Auipc_Opcode);
	assign isJAL		= (instrIn[6:2]==Jal_Opcode);
	assign isJALR		= (instrIn[6:2]==Jalr_Opcode);
	assign isBranch		= (instrIn[6:2]==Branch_Opcode);
	assign isSysCall	= (instrIn[6:2]==SysCall_Opcode);

	//shift amount for shifter
	//shamt moved to execution part
endmodule

`endif //RV32IDECODER_H