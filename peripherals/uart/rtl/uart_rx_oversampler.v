`ifndef UART_RX_OVERSAMPLER_H
`define UART_RX_OVERSAMPLER_H

module uart_rx_oversampler
(
	input wire baudClk //baud clock
	,input wire nRst //active low reset
	,input wire uartOverSamplerStart //sampler start
	,input wire baudOversampling //oversampling 8x or 16x
	,input wire uartRxLine //RX data line

	,output wire uartSampleBit //sampled final bit
	,output wire uartSampleReady //sample ready status
);

	//calculate correct sample from 3 samples around middle
	reg [4:0] sample_middle_bit; //middle bit for majority voting
	reg [4:0] sample_count; //counter
	
	//middle 3 bits
	reg [2:0] uart_sample_middle;

	assign uartSampleBit=(uart_sample_middle[0]&uart_sample_middle[1])|(uart_sample_middle[1]&uart_sample_middle[2])|(uart_sample_middle[2]&uart_sample_middle[0]);

	wire uart_oversampler_active;
	assign uart_oversampler_active=uartOverSamplerStart|uartSampleReady;

	reg uart_sample_ready;
	assign uartSampleReady=uart_sample_ready;

	reg first_bit;

	always @(posedge baudClk,negedge nRst)
	begin
		if(~nRst)
		begin
			uart_sample_middle<=0;
			sample_count<=0;
			uart_sample_ready<=0;
			first_bit<=0;
		end
		else
		begin
			sample_middle_bit<=(first_bit)? ((1<<(baudOversampling+2))-1):((1<<(baudOversampling+1))-1);
			
			if(uart_oversampler_active)
			begin
				//sample 3 middle bits
				if(sample_count==sample_middle_bit-1)
					uart_sample_middle[0]<=uartRxLine;
				else if(sample_count==sample_middle_bit)
					uart_sample_middle[1]<=uartRxLine;
				else if(sample_count==sample_middle_bit+1)
					uart_sample_middle[2]<=uartRxLine;
				
				if(sample_count==sample_middle_bit)
				begin
					uart_sample_ready<=1;
					sample_count<=0;
					first_bit<=1;
				end
				else
				begin
					uart_sample_ready<=0;				
					sample_count<=sample_count+1;
				end
			end
		end
	end

endmodule

`endif //UART_RX_OVERSAMPLER_H