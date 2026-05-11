`ifndef UART_RX_H
`define UART_RX_H

module uart_rx
#(
	parameter DATA_BITS=8
	,parameter ERR_BITS=2
)
(
	input wire baudClk //baud clock with oversampling
	,input wire nRst  //active low reset
	,input wire uartRxLine //input serial rx line

	,output reg [DATA_BITS-1:0] dataRx //output data received
	,output reg uartRxReady //status flag for complete frame received
	,output reg [ERR_BITS-1:0] uartRxErr //type of error occured
	,output wire uartRxBusy //Busy flag

	,input wire stopBits //0 for 1 stop bit, 1 for 2 stop bits
	,input wire parity	 //0 for even parity, 1 for odd parity
	,input wire baudOversampling //baud oversample rate
);
	reg [1:0] uart_state_rx;
	
	parameter BIT_INDEX=$clog2(DATA_BITS+1);
	reg [BIT_INDEX-1:0] bit_index;
	reg [DATA_BITS:0] uart_data_rx_parity;
	reg [1:0] stop_counter;

	localparam UART_STATE_IDLE=0;
	localparam UART_STATE_DATA=1;
	localparam UART_STATE_STOP=2;

	//error parameters
	localparam UART_ERR_PARITY=1;
	localparam UART_ERR_FRAME=2;

	reg uart_rx_parity;
	reg uart_rx_ready_1clk;
	reg uart_rx_ready_2clk;
	reg uart_oversampler_start;	//starts sampler
	wire uart_oversampler_start_wire;
	assign uart_oversampler_start_wire=uart_oversampler_start;
	wire uart_sample_ready; //signals fsm that filtering is done

	wire uart_rx_bit;

	uart_rx_oversampler
	uart_rx_oversampler_0
	(
		.baudClk              (baudClk)
		,.nRst                (nRst)
		,.uartRxLine          (uartRxLine)
		,.baudOversampling    (baudOversampling)
		,.uartOverSamplerStart(uart_oversampler_start_wire)
		,.uartSampleBit       (uart_rx_bit)
		,.uartSampleReady     (uart_sample_ready)
	);

	assign uartRxBusy=(uart_state_rx!=UART_STATE_IDLE);
	assign uartRxReady=uart_rx_ready_1clk^uart_rx_ready_2clk;

	always @(posedge baudClk,negedge nRst)
	begin
		if(~nRst)
		begin
			uart_state_rx<=UART_STATE_IDLE;
			bit_index<=0;
			uart_data_rx_parity<=0;
			uart_oversampler_start<=0;
			dataRx<=0;
			uart_rx_ready_1clk<=0;
			uart_rx_ready_2clk<=0;
		end
		else
		begin
			uart_rx_ready_2clk<=uart_rx_ready_1clk;
			case(uart_state_rx)
				UART_STATE_IDLE:
				begin
					if(uartRxLine==0)
					begin
						//start sampler and check for start
						uart_oversampler_start<=1;

						if(uart_sample_ready && uart_rx_bit==0)
						begin
							uart_state_rx<=UART_STATE_DATA;
							
							uartRxErr<=0;
							uart_rx_ready_1clk<=0;
							uart_rx_ready_2clk<=0;
							bit_index<=0;
							dataRx<=0;
							uart_rx_parity<=0;
						end
					end
				end
				UART_STATE_DATA:
				begin
					begin
						if(bit_index<DATA_BITS+1)	//include parity
						begin
							if(uart_sample_ready)
							begin
								uart_data_rx_parity[bit_index]<=uart_rx_bit;
								bit_index<=bit_index+1;
							end
						end
						else
						begin
							uart_rx_parity<=(parity==0)? (^uart_data_rx_parity):(~^uart_data_rx_parity);
							uart_state_rx<=UART_STATE_STOP;
							stop_counter<=0;
						end
					end
				end
				UART_STATE_STOP:
				begin
					if(uart_rx_parity==1)
					begin
						uartRxErr<=UART_ERR_PARITY;
						uart_state_rx<=UART_STATE_IDLE;
					end
					else
					begin
						if(uart_sample_ready)
						begin
							if(stop_counter<(stopBits+1))
								if(uart_rx_bit)
									stop_counter<=stop_counter+1;
								else
								begin
									uartRxErr<=UART_ERR_FRAME;
									uart_state_rx<=UART_STATE_IDLE;
								end
							else
							begin
								uart_rx_ready_1clk<=1;
								dataRx<=uart_data_rx_parity[DATA_BITS-1:0];
								uart_state_rx<=UART_STATE_IDLE;								
							end
						end
					end
				end
				default: uart_state_rx<=UART_STATE_IDLE;
			endcase
		end
	end
endmodule

`endif //UART_RX_H
