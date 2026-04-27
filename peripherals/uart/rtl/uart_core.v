`ifndef UART_CORE_H
`define UART_CORE_H

`define VERILATOR_TEST

module uart_core
#(
	parameter DATA_BITS=8
	,parameter BAUD_BITS=16
	,parameter ERR_BITS=2

	,parameter UART_ADDR_BITS=8
	,parameter UART_DATA_BITS=32
)
(
	input wire sysClk //system uart clock
	,input wire nRst //active low reset for uart

	,input wire [UART_ADDR_BITS-1:0] addrIn //uart memory mapped address
	,input wire [UART_DATA_BITS-1:0] dataIn //uart data in
	,output reg [UART_DATA_BITS-1:0] dataOut //uart data out
	,input wire wr //write-read signal

	,output wire intr //uart interrupt

	,output wire uartTxLine //uart serial out
	,input wire uartRxLine //uart serial in
);

	//local register mapped addresses
	localparam UART_REG_BASE		=8'h00;
	localparam UART_REG_WRITE 		=8'h00;
	localparam UART_REG_READ		=8'h04;
	localparam UART_REG_CONFIG		=8'h08;
	localparam UART_REG_STATUS		=8'h0C;
	localparam UART_REG_INT_STATUS	=8'h10;
	localparam UART_REG_INT_MASK  	=8'h14;
	localparam UART_REG_INT_CLR 	=8'h18;
	localparam UART_REG_END 		=8'h1C;
	
	parameter OVERSAMPLING_MULT=1;

	reg [DATA_BITS-1:0] reg_write;
	reg [DATA_BITS-1:0] reg_read;

	//interrupt control
	reg [(ERR_BITS+1)-1:0] reg_int_mask;
	reg [(ERR_BITS+1)-1:0] reg_int_signals;

	// reg [UART_DATA_BITS-1:0] reg_out_gpr;
	wire [DATA_BITS-1:0] uart_rx_data;
	
	//add options like tx enable, rx enable
	reg reg_start_tx;
	
	// test mode, parity, stop bits, oversampling bits, baud bits
	reg config_test_mode;
	wire config_test_mode_wire;

	assign config_test_mode_wire=config_test_mode;

	reg config_parity;
	reg config_stop_bits;
	reg config_os;
	reg [BAUD_BITS-1:0] config_baud;

	// address misaligned, tx busy, rx ready, err status
	wire uart_tx_busy;

	wire reg_uart_tx_busy;
	wire reg_uart_rx_busy;

`ifdef VERILATOR_TEST
	/* verilator lint_off UNUSED */
	wire [31:9] unused_data = dataIn[31:9];
	/* verilator lint_on UNUSED */
`endif

	assign reg_uart_tx_busy=uart_tx_busy|reg_start_tx;
	assign intr=|(reg_int_mask&reg_int_signals);

	always @(posedge sysClk,negedge nRst)
	begin
		if(~nRst)
		begin
			reg_write<=0;
			// reg_read<=0;
			reg_start_tx<=0;

			config_test_mode<=0;
			config_parity<=0;
			config_stop_bits<=0;
			config_os<=0;
			config_baud<=0;

			reg_int_mask<=0;
			reg_int_signals<=0;
		end
		else
		begin
			reg_read<=uart_rx_data;
			reg_int_signals<={uart_rx_err,uart_rx_ready};

			//not address dependent control reset
			if(uart_tx_busy)
				reg_start_tx<=0;

			case(addrIn)
				UART_REG_WRITE:
				begin
					if(~reg_uart_tx_busy)
					begin
						if(wr)
						begin
							reg_write[DATA_BITS-1:0]<=dataIn[DATA_BITS-1:0];
							reg_start_tx<=1;
						end
					end
				end

				UART_REG_READ:
				begin
					if(uart_rx_ready)
					begin
						if(~wr)
							dataOut<={24'd0,reg_read};
					end
				end

				UART_REG_CONFIG:
				begin
					if(~uart_tx_busy)
					begin
						if(wr)
						begin
							config_baud<=dataIn[BAUD_BITS-1:0]; //16
							config_os<=dataIn[BAUD_BITS]; //1
							config_parity<=dataIn[BAUD_BITS+OVERSAMPLING_MULT]; //1
							config_stop_bits<=dataIn[BAUD_BITS+OVERSAMPLING_MULT+1]; //1
							config_test_mode<=dataIn[BAUD_BITS+OVERSAMPLING_MULT+2]; //1
						end
					end
				end

				UART_REG_STATUS:
				begin
					if(~wr)
						dataOut<={{29{1'b0}},uart_rx_ready,reg_uart_rx_busy,reg_uart_tx_busy};
				end

				UART_REG_INT_STATUS:
				begin
					if(~wr)
						dataOut<={{(32-(ERR_BITS+1)){1'b0}},{uart_rx_err,uart_rx_ready}};
				end

				UART_REG_INT_MASK:
				begin
					if(wr)
						reg_int_mask<=dataIn[(ERR_BITS+1)-1:0];
				end

				UART_REG_INT_CLR:
				begin
					if(wr)
						reg_int_signals<=reg_int_signals&(~dataIn[(ERR_BITS+1)-1:0]);
				end

				default:
				begin
					dataOut<=0;
				end
			endcase
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
		,.startTx   (reg_start_tx)
		,.dataTx    (reg_write)
		,.uartTxLine(uartTxLine)
		,.uartTxBusy(uart_tx_busy)
		,.stopBits  (config_stop_bits)
		,.parity    (config_parity)
	);

	wire uart_rx_ready;
	wire [ERR_BITS-1:0] uart_rx_err;
	uart_rx
	#(
		.DATA_BITS        (DATA_BITS)
		,.ERR_BITS         (ERR_BITS)
	)
	uart_rx_0
	(
		.nRst             (nRst)
		,.parity          (config_parity)
		,.stopBits        (config_stop_bits)
		,.baudClk         (baud_clk_rx)
		,.baudOversampling(config_os)
		,.uartRxLine      (config_test_mode_wire? uartTxLine:uartRxLine)
		,.dataRx          (uart_rx_data)
		,.uartRxReady     (uart_rx_ready)
		,.uartRxErr       (uart_rx_err)
		,.uartRxBusy      (reg_uart_rx_busy)
	);

endmodule

`endif //UART_CORE_H