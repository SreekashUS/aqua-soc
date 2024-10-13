`include "../../regFile/regFile2R1W.v"
`include "../../branch/simple/simpleBranch.v"
`include "../../arb/tdmArbiter/tdmArbiter.v"
`include "../../core/RV32I/rv32iDecoder.v"
`include "../../core/alu/aluRv32i.v"
`include "../../utils/registers/pipelining/regParamCg.v"

/*
Main processor core here
Testing done with tests and makefiles with rv32i programs
*/

module aqua_pygmy
#(
	parameter MEM_DATA_WIDTH=32
	,parameter MEM_ADDR_WIDTH=32
)
(
	//Arbiter interface
	//I-access


	//D-access (Load/Store)

	//Interrupts etc


	//global signals
	input wire clk,reset
);
	//Default pipeline stages
	/*
	|- Fetch
	|- Decode
	|- Execute
	|- Writeback
	|- Memory access
	*/

	simpleBranch
	#(
	)
	simpleBranchInst
	(
		.clk        (clk)
		,.reset      (reset)
		
		//Stall until address is calculated
		,.pcStall    (pcStall)
		//Selection wire set by instruction type
		,.selWire    (selWire)
		//Target is calculated by ALU in this case
		,.jumpTarget1(aluOut)
		,.jumpTarget2(aluOut)
		,.jumpTarget3(aluOut)
		,.pc         (pc)
	);

	tdmArbiter
	#(
	)
	tdmArbiterInst
	(
		.clk          (clk)
		,.reset        (reset)

		,.memIAddr     (pc)
		,.reqI         (~pcStall)
		,.memIReady    (memIReady)

		//Load/Store instruction types
		,.memDAddr     (memDAddr)
		,.memDData     (memDData)
		,.wr           (wr)
		,.reqD         (reqD)
		,.memDReady    (memDReady)

		//Memory interface
		,.memBusyOut   (memBusyOut)
		,.memAddr      (memAddr)
		,.memWr        (memWr)
		,.memReq       (memReq)
		,.memDataIn    (memDataIn)
		,.memDataOut   (memDataOut)
		,.memDataOutReg(memDataOutReg)
	);

	//IF->DE pipeline registers
	regParamCg
	#(
		.WIDTH(32)
	)
	ifDeRegParamCgInst
	(
		.clk(clk)
		,.reset(reset)
		,.regIn(memDataOutReg)
		,.en(~pcStall)
		,.regOut(rv32iDecodeIn)
	);

	//DE (decoder)
	rv32iDecoder
	#(
	)
	rv32iDecoderInst
	(
		//instruction In
		.instrIn   (rv32iDecodeIn)

		//regFile operations and alu operations
		,.rs1       (rs1)
		,.rs2       (rs2)
		,.rd        (rd)
		,.funct3    (funct3)		//3
		,.funct7    (funct7)		//7
		,.opcode    (opcode)		//7
		,.instrType (instrType)		//3
		,.shamt     (shamt)			//5

		,.uImm      (uImm)			//31
		,.iImm      (iImm)			//31
		,.sImm      (sImm)			//31
		,.bImm      (bImm)			//31
		,.jImm      (jImm)			//31

		,.isLoad    (isLoad)		//1
		,.isStore   (isStore)		//1
		,.isMemOrder(isMemOrder)	//1
		,.isAluReg  (isAluReg)		//1
		,.isAluImm  (isAluImm)		//1
		,.isLui     (isLui)			//1
		,.isAuipc   (isAuipc)		//1
		,.isJAL     (isJAL)			//1
		,.isJALR    (isJALR)		//1
		,.isBranch  (isBranch)		//1
		,.isSysCall (isSysCall)		//1
	);

	//concat all necessary wires into the bus
	wire [190:0] deExWires;

	//DE->EX pipeline registers
	regParam
	#(
		.WIDTH()
	)
	deExRegParamInst
	(
		.clk   (clk)
		,.reset (reset)
		,.regIn (regIn)
		,.regOut(regOut)
	);
endmodule