`ifndef UART_RX_H
`define UART_RX_H

module uart_rx
#(
	parameter DATA_BITS=8
	,parameter ERR_BITS=2
	,parameter OVERSAMPLING_MULT=3
)
(
	input wire baudClk //baud clock with oversampling
	,input wire nRst  //active low reset
	,input wire uartRxLine //input serial rx line

	,output reg [DATA_BITS-1:0] dataRx //output data received
	,output reg uartRxReady //status flag for complete frame received
	,output reg [ERR_BITS-1:0] uartRxErr //type of error occured

	,input wire stopBits //0 for 1 stop bit, 1 for 2 stop bits
	,input wire parity	 //0 for even parity, 1 for odd parity
	,input wire [OVERSAMPLING_MULT-1:0] baudOversampling //baud oversample rate
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

	//calculate correct sample from 3 samples around middle
	reg [OVERSAMPLING_MULT:0] sample_middle_bit;
	reg [2:0] uart_sample_middle;
	reg [OVERSAMPLING_MULT:0] sample_count; //sample count based on baudOversampling
	reg uart_oversampler_start;	//starts sampler
	reg uart_sample_ready; //signals fsm that filtering is done
	wire uart_rx_bit;
	assign uart_rx_bit=(uart_sample_middle[0]&uart_sample_middle[1])|(uart_sample_middle[1]&uart_sample_middle[2])|(uart_sample_middle[2]&uart_sample_middle[0]);

	always @(posedge baudClk,negedge nRst)
	begin
		if(~nRst)
		begin
			uart_oversampler_start<=0;
			uart_sample_middle<=0;
			sample_count<=0;
		end
		else
		begin
			if(uart_oversampler_start)
			begin
				case(baudOversampling)
					0: //1x oversampling (direct uartRxLine)
					begin
						uart_sample_middle[0]<=uartRxLine;
						uart_sample_middle[1]<=uartRxLine;
						uart_sample_ready<=1;
					end
					1: //2x oversampling (sample index 1)
					begin
						if(sample_count<{1'b0,baudOversampling})
							sample_count<=sample_count+1;
						else
						begin
							uart_sample_middle[0]<=uartRxLine;
							uart_sample_middle[1]<=uartRxLine;
							uart_sample_ready<=1;
						end
					end

					//higher oversampling rate 4x (can use samples 1,2,3)
					default:
					begin
						//set middle bit
						sample_middle_bit<=(1<<(baudOversampling-1));

						//sample 3 middle bits
						if(sample_count==sample_middle_bit-1)
							uart_sample_middle[0]<=uartRxLine;
						else if(sample_count==sample_middle_bit)
							uart_sample_middle[1]<=uartRxLine;
						else if(sample_count==sample_middle_bit+1)
							uart_sample_middle[2]<=uartRxLine;
						
						if(sample_count==(1<<baudOversampling)-1)
						begin
							uart_sample_ready<=1;
							sample_count<=0;
						end
						else
						begin
							sample_count<=sample_count+1;
							uart_sample_ready<=0;					
						end
					end
				endcase
			end
		end
	end

	always @(posedge baudClk,negedge nRst)
	begin
		if(~nRst)
		begin
			uart_state_rx<=UART_STATE_IDLE;
			uartRxReady<=0;
			bit_index<=0;
			uart_sample_ready<=0;
			uart_data_rx_parity<=0;
		end
		else
		begin
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
							uartRxReady<=0;
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
								uartRxReady<=1;
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