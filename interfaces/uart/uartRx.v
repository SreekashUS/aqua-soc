`ifndef UARTRX_H
`define UARTRX_H

module uartRxMod
#(
	parameter CLOCK_DIV=54
	//Add parity bit that is included
	,parameter DATA_BITS=8
	,parameter STOP_BITS=1
)
(
	input wire clk,rst
	,input wire uartRx
	,output reg [DATA_BITS-1:0] dataRx
	,output reg uartReadyRx
	,output reg uartErrRx
);
	reg [1:0] uart_state_rx;
	
	parameter BIT_INDEX=$clog2(DATA_BITS+1);
	reg [BIT_INDEX-1:0] bit_index;

	parameter CLK_BITS=$clog2(CLOCK_DIV);
	reg [CLK_BITS-1:0] clk_count;

	localparam IDLE=0;
	localparam DATA=1;
	localparam STOP=2;

	always @(posedge clk,posedge rst)
	begin
		if(rst)
		begin
			uart_state_rx<=IDLE;
			uartReadyRx<=0;
			bit_index<=0;
		end
		else
		begin
			case(uart_state_rx)
				IDLE:
				begin
					if(uartRx==0)
					begin
						uart_state_rx<=DATA;
						clk_count<=0;
						uartErrRx<=0;
						uartReadyRx<=0;
						bit_index<=0;
						dataRx<=0;
					end
				end
				DATA:
				begin
					if(clk_count<CLOCK_DIV-1)
						clk_count<=clk_count+1;
					else
					begin
						clk_count<=0;
						if(bit_index<DATA_BITS)
						begin
							dataRx[bit_index]<=uartRx;
							bit_index<=bit_index+1;
						end
						else
						begin
							//raise single bit parity error
							uartErrRx<=~(uartRx==^dataRx[DATA_BITS-2:0]);
							uart_state_rx<=STOP;
						end
					end
				end
				STOP:
				begin
					uartReadyRx<=1;
					if(clk_count<=CLOCK_DIV-1)
					begin
						clk_count<=clk_count+1;
						uart_state_rx<=STOP;
					end
					else
						uart_state_rx<=IDLE;
				end
				default: uart_state_rx<=IDLE;
			endcase
		end
	end
endmodule

`endif //UARTRX_H