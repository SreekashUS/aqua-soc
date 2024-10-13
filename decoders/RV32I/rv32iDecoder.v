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
	,output wire [REG_COUNT-1:0]	rd
	,output wire [2:0]				funct3
	,output wire [6:0]				funct7
	,output wire [6:0]				opcode
	,output wire [2:0]				instrType
	,output wire [4:0]				shamt
	,output wire [XLEN-1:0]		uImm
	,output wire [XLEN-1:0]		iImm
	,output wire [XLEN-1:0]		sImm
	,output wire [XLEN-1:0]		bImm
	,output wire [XLEN-1:0]		jImm

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
	assign rd 		=instrIn[11:7];
	assign rs1		=instrIn[19:15];
	assign rs2		=instrIn[24:20];
	//Immediates
	assign iImm 	={{21{instrIn[31]}},instrIn[30:20]};
	assign sImm 	={{21{instrIn[31]}},instrIn[30:25],instrIn[11:7]};
	assign bImm 	={{20{instrIn[31]}},instrIn[7],instrIn[30:25],instrIn[11:8],1'b0};
	assign uImm 	={instrIn[31:12],12'b0};
	assign jImm 	={{12{instrIn[31]}},instrIn[19:12],instrIn[20],instrIn[30:21],1'b0};
	//type of instruction
	assign isLoad		= (instrIn[7:2]==Load_Opcode);
	assign isStore		= (instrIn[7:2]==Store_Opcode);
	assign isMemOrder	= (instrIn[7:2]==MemOrder_Opcode);
	assign isAluReg		= (instrIn[7:2]==AluReg_Opcode);
	assign isAluImm		= (instrIn[7:2]==AluImm_Opcode);
	assign isLui		= (instrIn[7:2]==Lui_Opcode);
	assign isAuipc		= (instrIn[7:2]==Auipc_Opcode);
	assign isJAL		= (instrIn[7:2]==Jal_Opcode);
	assign isJALR		= (instrIn[7:2]==Jalr_Opcode);
	assign isBranch		= (instrIn[7:2]==Branch_Opcode);
	assign isSysCall	= (instrIn[7:2]==SysCall_Opcode);

	//function for ALU or other units based in instruction type
	assign funct3 		= (instrIn[14:12]);
	//shift amount for shifter
	assign shamt 		= (instrIn[24:20]);
endmodule

`endif //RV32IDECODER_H