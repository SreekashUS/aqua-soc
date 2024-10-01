`ifndef UARTTX_H
`define UARTTX_H

`define USE_SINGLE_PARITY

module uartTx
#(
	//BAUD rate=115200 and clock frequency=50MHz
    // parameter CLOCK_DIV=434
	//BAUD rate=921600 and clock frequency=50MHz
    parameter CLOCK_DIV=54
`ifdef USE_SINGLE_PARITY
    ,parameter DATA_BITS=7+1
`else
    ,parameter DATA_BITS=7
`endif

    ,parameter STOP_BITS=1
)
(
    input wire clk,rst,
    //start signal
    input wire start,
    //data to be transmitted
    input wire [DATA_BITS-1:0] data,
    //uart_tx line
    output reg uart_tx,
    //uart busy uart_state
    output reg busy
);
    reg [3:0] uart_state;

    parameter BIT_INDEX=$clog2(DATA_BITS);
    reg [BIT_INDEX-1:0] bit_index;

    parameter CLK_BITS=$clog2(CLOCK_DIV);
    reg [CLK_BITS-1:0] clk_count;

    //UART uart_states
    localparam IDLE=0;
    localparam START=1;
    localparam DATA=2;
    localparam STOP=3;

`ifdef USE_SINGLE_PARITY
    reg parityBit;
`endif

    always @(posedge clk,posedge rst) 
    begin
        if (rst) 
        begin
            uart_state<=IDLE;
            uart_tx<=1;
            busy<=0;
            clk_count<=0;
            bit_index<=0;
        end 
        else 
        begin
            case (uart_state)
                IDLE:
                begin
                    uart_tx<=1;
                    busy<=0;
                    if (start) 
                    begin
                        uart_state<=START;
                        busy<=1;
                        //even parity
                        parityBit=^data;
                    end
                end
                
                START: 
                begin
                    uart_tx<=0;
                    clk_count<=0;
                    uart_state<=DATA;
                end
                
                DATA: 
                begin
                    //Pulse generator for required Baud rate
                    if (clk_count<CLOCK_DIV-1) 
                    begin
                        clk_count<=clk_count+1;
                    end

                    //else send data
                    else 
                    begin
                        clk_count<=0;

                        if (bit_index<DATA_BITS-2)
                        begin 
                            bit_index<=bit_index+1;
                        	uart_tx<=data[bit_index];
                        end
`ifdef USE_SINGLE_PARITY
                        else if(bit_index==DATA_BITS-1)
                        begin
                        	uart_tx<=parityBit;
                        end
`endif
                        else
                        begin
                            bit_index<=0;
                            uart_state<=STOP;
                        end
                    end
                end
                
                //Single stop bit
                STOP: 
                begin
                    uart_tx<=1;
                    uart_state<=IDLE;
                end
                
                default: uart_state<=IDLE;
            endcase
        end
    end
endmodule

`endif //UARTTX_H