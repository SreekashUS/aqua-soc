`ifndef UART_ENGINE_H
`define UART_ENGINE_H

module uart_engine
#(
	parameter BAUD_BITS=16
	,DATA_BITS=8
	,ERR_BITS=2
)
(
	//global
	input wire clk
	,input wire nRst

	//baud generator control
	,input wire [BAUD_BITS-1:0] configBaudGen
	,input wire configOs

	//frame control
	,input wire configStopBits
	,input wire configParity

	//tx wires and soft reset tx
	,input wire nRstTxSft
	,input wire txStart
	,input wire [DATA_BITS-1:0] txWriteData
	,output wire txBusy
	,output wire uartTxLine

	//rx wires and soft reset rx
	,input wire nRstRxSft
	,input wire uartRxLine 
	,output wire [DATA_BITS-1:0] rxReadData
	,output wire rxReady
	,output wire [ERR_BITS-1:0] rxErr
	,output wire rxBusy

	//datapath and enable control
	,input wire testEnable
	,input wire txEnable
	,input wire rxEnable
);

	wire baud_clk_tx,baud_clk_rx;

	//baud generator instance
	baud_generator_int
	#(
		.BAUD_BITS(BAUD_BITS)
	)
	baud_generator_int_0
	(
		.clk          	  (clk)
		,.nRst            (nRst)
		,.baudClkTx       (baud_clk_tx)
		,.baudClkRx       (baud_clk_rx)
		,.baudDivisor     (configBaudGen)
		,.baudOversampling(configOs)
	);

	//tx instance
	uart_tx
	#(
		.DATA_BITS(DATA_BITS)
	)
	uart_tx_0
	(
		.nRst      (nRst&(~nRstTxSft))
		,.baudClk   (baud_clk_tx)
		,.startTx   (txStart)
		,.dataTx    (txWriteData)
		,.uartTxLine(uartTxLine)
		,.uartTxBusy(txBusy)
		,.stopBits  (configStopBits)
		,.parity    (configParity)
	);

	uart_rx
	#(
		.DATA_BITS        (DATA_BITS)
		,.ERR_BITS         (ERR_BITS)
	)
	uart_rx_0
	(
		.nRst             (nRst&(~nRstRxSft))
		,.parity          (configParity)
		,.stopBits        (configStopBits)
		,.baudClk         (baud_clk_rx)
		,.baudOversampling(configOs)
		,.uartRxLine      (testEnable? uartTxLine:uartRxLine)
		,.dataRx          (rxReadData)
		,.uartRxReady     (rxReady)
		,.uartRxErr       (rxErr)
		,.uartRxBusy      (rxBusy)
	);

endmodule

`endif //UART_ENGINE_H
