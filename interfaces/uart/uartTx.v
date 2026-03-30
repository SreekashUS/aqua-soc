`ifndef UARTTX_H
`define UARTTX_H

`include "../utils/baud_generators.v"

module UartTx
#(
    parameter DATA_BITS=8
    ,parameter STOP_BITS=1
    ,parameter BAUD_BITS=16
)
(
    input wire clk,rst,
    //startTx signal
    input wire startTx,
    //dataTx to be transmitted
    input wire [DATA_BITS-1:0] dataTx,
    //configurable baud
    input wire [BAUD_BITS-1:0] divisor,
    //uartTx line
    output reg uartTx,
    //uartBusyTx
    output wire uartBusyTx
);
    reg [1:0] uart_state_tx;

    parameter BIT_INDEX=$clog2(DATA_BITS+1);
    reg [BIT_INDEX-1:0] bit_index;

    parameter STOP_BIT_COUNTER=$clog2(STOP_BITS+1);
    reg [STOP_BIT_COUNTER-1:0] stop_counter;

    //UART uart_states
    localparam UART_STATE_IDLE=0;
    localparam UART_STATE_START=1;
    localparam UART_STATE_DATA=2;
    localparam UART_STATE_STOP=3;

    assign uartBusyTx=~(uart_state_tx==UART_STATE_IDLE);

    //added for even parity
    reg [DATA_BITS-1+1:0] dataReg;

    //from baud generator
    wire baud_clk;

    //Integer baud generator instance
    BaudGeneratorInt 
    #(.BAUD_BITS(BAUD_BITS))
    gen
    (
        .clk(clk),
        .rst(rst),
        .divisor(divisor),
        .baud_clk(baud_clk)
    );

    always @(posedge baud_clk,posedge rst) 
    begin
        if (rst) 
        begin
            uart_state_tx<=UART_STATE_IDLE;
            uartTx<=1;
            bit_index<=0;
        end 
        else 
        begin
            case (uart_state_tx)
                UART_STATE_IDLE:
                begin
                    uartTx<=1;
                    if (startTx) 
                    begin
                        bit_index<=0;
                        uart_state_tx<=UART_STATE_START;
                    end
                end
                
                UART_STATE_START: 
                begin
                    uartTx<=0;
                    uart_state_tx<=UART_STATE_DATA;
                    //put even parity bit within the dataReg
                    dataReg<={^dataTx,dataTx};
                end
                
                UART_STATE_DATA: 
                begin
                    if (bit_index<DATA_BITS+1)
                    begin
                        bit_index<=bit_index+1;
                    	uartTx<=dataReg[bit_index];
                    end
                    else
                    begin
                        bit_index<=0;
                        uart_state_tx<=UART_STATE_STOP;
                        stop_counter<=0;
                    end
                end
                
                //Single stop bit at the baud rate
                UART_STATE_STOP: 
                begin
                    if(stop_counter<STOP_BITS)
                    begin
                        uartTx<=1;
                        stop_counter<=stop_counter+1;
                    end
                    else
                    begin
                        stop_counter<=0;
                        uart_state_tx<=UART_STATE_IDLE;
                    end
                end
                
                default: uart_state_tx<=UART_STATE_IDLE;
            endcase
        end
    end
endmodule

`endif //UARTTX_H