interface uart_if 
#(
	parameter AW=8
	,parameter DW=32
)
(
	input logic clk
);
	mmio_if m_mmio_if(.clk(clk));

	//include irq for now
	logic irq;

	//include PHY tx, rx lines
	logic tx;
	logic rx;
endinterface : uart_if