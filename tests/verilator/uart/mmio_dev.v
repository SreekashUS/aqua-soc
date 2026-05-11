`ifndef MMIO_DEV_H
`define MMIO_DEV_H

module mmio_dev
#(
	parameter DATA_BITS=8
	,parameter BAUD_BITS=16
	,parameter ERR_BITS=2

	,parameter UART_ADDR_BITS=8
	,parameter UART_DATA_BITS=32
)
(
	input wire clk
	,input wire nRst
	,input wire [UART_ADDR_BITS-1:0] addrIn
	,input wire [UART_DATA_BITS-1:0] dataIn
	,output reg [UART_DATA_BITS-1:0] dataOut
	,input wire wr
	,output wire intr
	,output wire uartTxLine
	,input wire uartRxLine
	,input wire valid
	,output wire busy
);
	uart_core
	uart_core_0
	(
		.clk       (clk)
		,.nRst      (nRst)
		,.addrIn    (addrIn)
		,.dataIn    (dataIn)
		,.dataOut   (dataOut)
		,.wr        (wr)
		,.intr      (intr)
		,.uartTxLine(uartTxLine)
		,.uartRxLine(uartRxLine)
		,.busy      (busy)
		,.valid     (valid)
	);

endmodule

`endif //MMIO_DEV_H
