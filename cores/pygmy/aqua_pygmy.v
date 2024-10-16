// `define SIM
`ifdef SIM
	`include "../../regFile/regFile2R1W.v"
	`include "../../branch/simple/simpleBranch.v"
	`include "../../arb/tdmArbiter/tdmArbiter.v"
	`include "../../decoders/RV32I/rv32iDecoder.v"
	`include "../../exec/alu/aluRv32i.v"
	`include "../../utils/registers/pipelining/regParamCg.v"
	`include "../../utils/registers/pipelining/regParam.v"
`endif

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
	//Arbiter access to memory
	output wire [MEM_ADDR_WIDTH-1:0] memAddr
	,output wire memWr
	,output wire memReq
	,output wire [MEM_DATA_WIDTH-1:0] memDataIn
	,input wire memBusyOut
	,input wire [MEM_DATA_WIDTH-1:0] memDataOut
	
	//Interrupts etc

	//global signals
	,input wire clk,reset
);
	//Default pipeline stages
	/*
	|- Before Fetch (Update PC->not pipeRegs)

	|- Fetch
	|- Decode
	|- Execute
	|- Memory access
	|- Writeback
	*/

	//Before IF (always active updating PC based on flow)
	simpleBranch
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

	//IF stage
	//IF interface for both I-data and D-data accesses
	tdmArbiter
	tdmArbiterInst
	(
		.clk          (clk)
		,.reset        (reset)

		//I-data
		,.memIAddr     (pc)
		,.reqI         (~pcStall)
		,.memIReady    (memIReady)

		//D-data
		//Connect here from MEM stage (Loads/Stores)
		//TODO
		,.memDAddr     (resultOut)
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

		//actual data received here
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
		//First part handles stall logic, second when I-data is ready
		,.en((~pcStall)&&(memIReady))
		,.regOut(rv32iDecodeIn)
	);

	//DE stage (Do partial decoding now and send rs1,rs2 to regFile)
	rv32iDecoder rv32iDecoderInst
	(
		//instruction In
		.instrIn   (rv32iDecodeIn)

		//DE regFile operations and alu operations
		,.rs1       (rs1)
		,.rs2       (rs2)

		//EX
		,.immsRdShamt(immsRdShamt)	//25 bits compressed for immediates,rd and shamt

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

	//regFile (both in DE and WB stage)
	regFile2R1W regFile2R1WInst
	(
		.clk    (clk)
		,.rst    (rst)
		,.rs1    (rs1)
		,.rs2    (rs2)
		,.dataRs1(dataRs1)
		,.dataRs2(dataRs2)
		,.rd     (rd)
		,.dataRd (dataRd)
	);

	//concat all necessary wires into the bus
	//Immediates+Rd+Shift amount in the top 25 wires+
	//Decoded operation wires
	wire [25+11-1:0] deExRegIn;
	
	assign deExRegIn={
	immsRdShamt
	,isLoad
	,isStore
	,isMemOrder
	,isAluReg
	,isAluImm
	,isJAL
	,isJALR
	,isBranch
	,isSysCall
	};

	//DE->EX pipeline registers
	regParam deExRegParamInst
	(
		.clk   (clk)
		,.reset (reset)
		,.regIn (deExRegIn)
		,.regOut(deExRegOut)
	);

	//EX stage (and partial decode from immsRdShamt)
	/*
	Multiplex
		- input1 as regFile rs1 or PC
		- input2 as regFile rs2 or Imm or shamt
	*/
	wire [MEM_DATA_WIDTH-1:0] input1In,input2In;

	// assign input1in=(isAluReg)? dataRs1:pc;
	// assign input2in=(isAluReg)? dataRs2:imms;

	aluRv32i aluRv32iInst
	(
		.input1In (input1In)
		,.input2In (input2In)
		,.opType   (opType)
		,.resultOut(resultOut)
	);

	//EX->MEM pipeline registers
	regParam exMemRegParamInst
	(
		.clk   (clk)
		,.reset (reset)
		,.regIn (regIn)
		,.regOut(regOut)
	);

	//MEM stage
	//Check the arbiter memory interface for MEM access

	//MEM->WB pipeline registers
	/*
	Rd needed
	*/
	regParam memWbRegParamInst
	(
		.clk   (clk)
		,.reset (reset)
		,.regIn (regIn)
		,.regOut(regOut)
	);

endmodule