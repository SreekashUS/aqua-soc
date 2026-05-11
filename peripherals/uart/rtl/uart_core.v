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
	input wire clk //system uart clock
	,input wire nRst //active low reset for uart

	,input wire [UART_ADDR_BITS-1:0] addrIn //uart memory mapped address
	,input wire [UART_DATA_BITS-1:0] dataIn //uart data in
	,output reg [UART_DATA_BITS-1:0] dataOut //uart data out
	,input wire wr //write-read signal
	,input wire valid //valid signal for mmio transaction
	,output wire ready //backpressure/stall control from uart core

	,output wire intr //uart interrupt

	,output wire uartTxLine //uart serial out
	,input wire uartRxLine //uart serial in
);

	//local register mapped addresses
	localparam UART_REG_BASE		=8'h00;
	localparam UART_REG_WRITE 		=8'h00;
	localparam UART_REG_READ		=8'h04;
	localparam UART_REG_CONFIG		=8'h08;
	localparam UART_REG_CONTROL		=8'h0C;
	localparam UART_REG_RESET		=8'h10;
	localparam UART_REG_STATUS		=8'h14;
	localparam UART_REG_INT_STATUS	=8'h18;
	localparam UART_REG_INT_MASK  	=8'h1C;
	localparam UART_REG_INT_PEND	=8'h20;
	localparam UART_REG_INT_CLR 	=8'h24;
	localparam UART_REG_END 		=8'h28;
	
	parameter OVERSAMPLING_MULT=1;

	//uart write and read data
	reg [DATA_BITS-1:0] reg_write;
	reg [DATA_BITS-1:0] reg_read;

	//interrupt control
	reg [(ERR_BITS+1)-1:0] reg_int_mask;
	reg [(ERR_BITS+1)-1:0] reg_int_signals;
	reg [(ERR_BITS+1)-1:0] reg_int_pend;
	reg irq_pending;

	// wire [DATA_BITS-1:0] uart_rx_data;
	
	// additional control/configuration
	reg reg_start_tx;
	reg reg_enable_tx;
	reg reg_enable_rx;
	reg reg_reset_tx;
	reg reg_reset_tx_in;
	reg reg_reset_tx_1clk;
	reg reg_reset_rx;
	reg reg_reset_rx_in;
	reg reg_reset_rx_1clk;

	wire test_available;
	assign test_available=reg_enable_tx&reg_enable_rx;
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

	wire uart_rx_ready;
	wire [ERR_BITS-1:0] uart_rx_err;

	wire reg_uart_tx_busy;
	wire reg_uart_rx_busy;

`ifdef VERILATOR_TEST
	/* verilator lint_off UNUSED */
	wire [31:9] unused_data=dataIn[31:9];
	/* verilator lint_on UNUSED */
`endif

	assign reg_uart_tx_busy=uart_tx_busy|reg_start_tx;

	assign intr=|(reg_int_pend);

	always @(*)
	begin
		case(addrIn)
			UART_REG_WRITE:
			begin
				ready=~reg_uart_tx_busy;
			end

			UART_REG_CONFIG:
			begin
				ready=~(reg_uart_tx_busy|reg_uart_rx_busy);
			end

			UART_REG_CONTROL:
			begin
				ready=~(reg_uart_tx_busy|reg_uart_rx_busy);				
			end

			default:
			begin
				ready=1;
			end
		endcase
	end

	always @(posedge clk,negedge nRst)
	begin
		if(~nRst)
		begin
			reg_write<=0;
			reg_start_tx<=0;

			reg_enable_tx<=0;
			reg_enable_rx<=0;
			reg_reset_tx<=1;
			reg_reset_rx<=1;
			reg_reset_tx_1clk<=0;
			reg_reset_rx_1clk<=0;
			reg_reset_tx_in<=0;
			reg_reset_rx_in<=0;

			config_test_mode<=0;
			config_parity<=0;
			config_stop_bits<=0;
			config_os<=0;
			config_baud<=0;

			reg_int_mask<=0;
			reg_int_signals<=0;
			reg_int_pend<=0;
			irq_pending<=0;
		end
		else
		begin
			//soft resets
			reg_reset_tx_1clk<=reg_reset_tx_in;
			reg_reset_rx_1clk<=reg_reset_rx_in;

			reg_reset_tx<=(~reg_reset_tx_1clk)&reg_reset_tx_in;
			reg_reset_rx<=(~reg_reset_rx_1clk)&reg_reset_rx_in;

			// reg_read<=uart_rx_data;
			reg_int_signals<={uart_rx_err,uart_rx_ready};
			
			if(~irq_pending)
			begin
				reg_int_pend<=reg_int_mask&reg_int_signals;
				if(reg_int_pend!=0)
					irq_pending<=1;
			end

			//not address dependent control reset
			if(uart_tx_busy)
				reg_start_tx<=0;

			if(valid)
			begin
				case(addrIn)
					UART_REG_WRITE:
					begin
						//should not write if fifo is full (or in this case tx busy)
						if(reg_enable_tx)
						begin
							if(wr)
							begin
								if(~reg_uart_tx_busy)
								begin
									reg_write[DATA_BITS-1:0]<=dataIn[DATA_BITS-1:0];
									reg_start_tx<=1;
								end
							end
						end
					end

					UART_REG_READ:
					begin
						if(reg_enable_rx&reg_int_pend[0])
						begin
							if(~wr)
								dataOut<={24'd0,reg_read};
						end
					end

					UART_REG_CONFIG:
					begin
						if(wr)
						begin
							if(~(uart_tx_busy|reg_uart_rx_busy))
							begin
								config_baud<=dataIn[BAUD_BITS-1:0]; //16
								config_os<=dataIn[BAUD_BITS]; //1
								config_parity<=dataIn[BAUD_BITS+OVERSAMPLING_MULT]; //1
								config_stop_bits<=dataIn[BAUD_BITS+OVERSAMPLING_MULT+1]; //1
							end
						end
						// issue from verilator
						// else
						// begin
						// 	dataOut<={{13{1'd0}},config_stop_bits,config_parity,config_os,config_baud};
						// end
					end

					UART_REG_CONTROL:
					begin
						if(wr)
						begin
							if(dataIn[0])
								reg_enable_tx<=1;
							else if(~uart_tx_busy)
								reg_enable_tx<=0;

							if(dataIn[1])
								reg_enable_rx<=1;
							else if(~reg_uart_rx_busy)
								reg_enable_rx<=0;

							if(dataIn[0]&dataIn[1]&dataIn[2])
								config_test_mode<=1;
							else
								config_test_mode<=0;
						end
						else
						begin
							dataOut<={{27{1'd0}},config_test_mode,reg_reset_rx,reg_reset_tx,reg_enable_rx,reg_enable_tx};
						end
					end

					UART_REG_RESET:
					begin
						if(wr)
						begin
							reg_reset_tx_in<=~dataIn[0];
							reg_reset_rx_in<=~dataIn[1];
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
							dataOut<={{(32-(ERR_BITS+1)){1'b0}},reg_int_pend};
					end

					UART_REG_INT_MASK:
					begin
						if(wr)
							reg_int_mask<=dataIn[(ERR_BITS+1)-1:0];
						else
							dataOut<={{(32-(ERR_BITS+1)){1'd0}},reg_int_mask};
					end

					UART_REG_INT_CLR:
					begin
						if(wr)
						begin
							reg_int_signals<=reg_int_signals&(~dataIn[(ERR_BITS+1)-1:0]);
							if(reg_int_signals==0)
								irq_pending<=0;
						end
					end

					default:
					begin
						dataOut<=0;
					end
				endcase
			end
		end
	end


	uart_engine
	#(
		.BAUD_BITS(BAUD_BITS)
		,.DATA_BITS(DATA_BITS)
		,.ERR_BITS (ERR_BITS)
	)
	uart_engine_0
	(
		.clk            (clk)
		,.nRst          (nRst)
		,.uartRxLine    (uartRxLine)
		,.uartTxLine    (uartTxLine)
		,.configBaudGen (config_baud)
		,.configOs      (config_os)
		,.configStopBits(config_stop_bits)
		,.configParity  (config_parity)
		,.nRstTxSft     (reg_reset_tx)
		,.txStart       (reg_start_tx)
		,.txWriteData   (reg_write)
		,.txBusy        (uart_tx_busy)
		,.nRstRxSft     (reg_reset_rx)
		,.rxReadData    (reg_read)
		,.rxReady       (uart_rx_ready)
		,.rxErr         (uart_rx_err)
		,.rxBusy        (reg_uart_rx_busy)
		,.testEnable    (config_test_mode_wire)
		,.txEnable      (reg_enable_tx)
		,.rxEnable      (reg_enable_rx)
	);

endmodule

`endif //UART_CORE_H
