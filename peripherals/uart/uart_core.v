`ifndef UART_CORE_H
`define UART_CORE_H

`define VERILATOR_TEST

module uart_core
#(
	parameter DATA_BITS=8
	,parameter BAUD_BITS=16
	,parameter OVERSAMPLING_MULT=3
	,parameter ERR_BITS=2

	,parameter UART_ADDR_BITS=32
	,parameter UART_DATA_BITS=32
)
(
	input wire sysClk //system uart clock
	,input wire nRst //active low reset for uart

	,input wire [UART_ADDR_BITS-1:0] addrIn //uart memory mapped address
	,input wire [UART_DATA_BITS-1:0] dataIn //uart data in
	,output reg [UART_DATA_BITS-1:0] dataOut //uart data out
	,input wire wr //write-read signal

	// ,output wire interrupt //uart interrupt

	,output wire uart_tx_line //uart serial out
	,input wire uart_rx_line //uart serial in
);

	//physical address mapped
	localparam UART_REG_BASE			=32'hF000_0000;
	localparam UART_REG_WRITE_OFF 		=32'hF000_0000;
	localparam UART_REG_READ_OFF		=32'hF000_0004;
	localparam UART_REG_CONTROL_OFF 	=32'hF000_0008;
	localparam UART_REG_CONFIG_OFF		=32'hF000_000C;
	localparam UART_REG_STATUS_OFF		=32'hF000_0010;
	localparam UART_REG_END 			=32'hF000_0014;
	// localparam UART_REG_INTERRUPT_STATUS_OFF=8'h14;
	// localparam UART_REG_INTERRUPT_MASK_OFF=8'h18;

	reg [DATA_BITS-1:0] reg_write;
	// reg [DATA_BITS-1:0] reg_read;

	// reg [UART_DATA_BITS-1:0] reg_out_gpr;
	// wire [DATA_BITS-1:0] uart_rx_data;
	
	//add options like tx enable, rx enable
	reg reg_control;
	
	// test mode, parity, stop bits, oversampling bits, baud bits
	reg config_test_mode;
	reg config_parity;
	reg config_stop_bits;
	reg [OVERSAMPLING_MULT-1:0] config_os;
	reg [BAUD_BITS-1:0] config_baud;

	// address misaligned, tx busy, rx ready, err status
	wire uart_tx_busy;

	reg reg_uart_tx_busy;

`ifdef VERILATOR_TEST
	/* verilator lint_off UNUSED */
	wire [31:9] unused_data = dataIn[31:9];
	/* verilator lint_on UNUSED */
`endif

	always @(posedge sysClk,negedge nRst)
	begin
		if(~nRst)
		begin
			reg_write<=0;
			// reg_read<=0;
			reg_control<=0;

			config_test_mode<=0;
			config_parity<=0;
			config_stop_bits<=0;
			config_os<=0;
			config_baud<=0;

			// int_addr<=0;
		end
		else
		begin
			//1 cycle delay of status reg
			reg_uart_tx_busy<=uart_tx_busy;

			//validate address range
			if(addrIn>=UART_REG_BASE && addrIn<=UART_REG_END)
			begin
				case(addrIn)
					UART_REG_WRITE_OFF:
					begin
						if(wr)
							reg_write[DATA_BITS-1:0]<=dataIn[DATA_BITS-1:0];
					end

					UART_REG_CONTROL_OFF:
					begin
						if(~uart_tx_busy)
						begin
							if(wr)
								reg_control<=dataIn[0];
						end
						else
						begin
							reg_control<=0;
						end
					end

					UART_REG_CONFIG_OFF:
					begin
						if(~uart_tx_busy)
						begin
							if(wr)
							begin
								config_baud<=dataIn[BAUD_BITS-1:0];
								config_os<=dataIn[BAUD_BITS+(OVERSAMPLING_MULT-1):BAUD_BITS];
								config_parity<=dataIn[BAUD_BITS+OVERSAMPLING_MULT];
								config_stop_bits<=dataIn[BAUD_BITS+OVERSAMPLING_MULT+1];
								config_test_mode<=dataIn[BAUD_BITS+OVERSAMPLING_MULT+2];
							end
						end
					end

					UART_REG_STATUS_OFF:
					begin
						if(~wr)
							dataOut<={{31{1'b0}},reg_uart_tx_busy};
					end

					default:
					begin
						//blank for now
					end
				endcase
			end
		end
	end

	wire baud_clk_tx;
	wire baud_clk_rx;

	//baud generator instance
	baud_generator_int
	#(
		.BAUD_BITS(BAUD_BITS)
	)
	baud_generator_int_0
	(
		.sysClk          (sysClk)
		,.nRst            (nRst)
		,.baudClkTx       (baud_clk_tx)
		,.baudClkRx       (baud_clk_rx)
		,.baudDivisor     (config_baud)
		,.baudOversampling(config_os)
	);

	//tx instance
	uart_tx
	#(
		.DATA_BITS(DATA_BITS)
	)
	uart_tx_0
	(
		.nRst      (nRst)
		,.baudClk   (baud_clk_tx)
		,.startTx   (reg_control)
		,.dataTx    (reg_write)
		,.uartTxLine(uart_tx_line)
		,.uartTxBusy(uart_tx_busy)
		,.stopBits  (config_stop_bits)
		,.parity    (config_parity)
	);

	// wire uart_rx_ready;
	// wire [ERR_STATUS:0] uart_rx_err;
	// uart_rx
	// #(
	// 	.DATA_BITS        (DATA_BITS)
	// 	,.ERR_BITS         (ERR_BITS)
	// 	,.OVERSAMPLING_MULT(OVERSAMPLING_MULT)
	// )
	// uart_rx_0
	// (
	// 	.nRst            (nRst)
	// 	,.parity          (reg_config[CONFIG_PARITY])
	// 	// ,.parity          (0)
	// 	,.stopBits        (reg_config[CONFIG_STOP_BITS])
	// 	// ,.stopBits        (0)
	// 	,.baudClk         (baud_clk_rx)
	// 	,.baudOversampling(reg_config[OVERSAMPLING_MULT+CONFIG_BAUD_BITS-1:CONFIG_BAUD_BITS])
	// 	// ,.uartRxLine      (reg_config[CONFIG_TEST]? (uart_tx_line):(uart_rx_line))
	// 	,.uartRxLine      (uart_rx_line)
	// 	,.dataRx          (uart_rx_data)
	// 	,.uartRxReady     (uart_rx_ready)
	// 	,.uartRxErr       (uart_rx_err)
	// );

endmodule

`endif //UART_CORE_H