`ifndef UART_TX_H
`define UART_TX_H

module uart_tx
#(
    parameter DATA_BITS=8
)
(
    input wire baudClk //baud clock generated fromm baud clock generator
    ,input wire nRst   //active low reset
    
    ,input wire startTx //start signal
    ,input wire [DATA_BITS-1:0] dataTx //input data to be transmitted
    ,output reg uartTxLine //output serial tx line
    ,output reg uartTxBusy //uart tx busy flag

    //additional config
    ,input wire stopBits  //0 for 1 stop bit, 1 for 2 stop bits
    ,input wire parity    //0 for even parity, 1 for odd parity
);
    reg [1:0] uart_state_tx;

    parameter BIT_INDEX=$clog2(DATA_BITS+1);
    reg [BIT_INDEX-1:0] bit_index;

    parameter STOP_BIT_COUNTER=2;
    reg [STOP_BIT_COUNTER-1:0] stop_counter;

    //UART uart_states
    localparam UART_STATE_IDLE=0;
    localparam UART_STATE_START=1;
    localparam UART_STATE_DATA=2;
    localparam UART_STATE_STOP=3;

    //added for even parity
    reg [DATA_BITS-1+1:0] dataReg;

    // assign uartTxBusy=~(uart_state_tx==UART_STATE_IDLE);

    always @(posedge baudClk,negedge nRst) 
    begin
        //async reset
        if(~nRst)
        begin
            uart_state_tx<=UART_STATE_IDLE;
            uartTxLine<=1;
            bit_index<=0;
            uartTxBusy<=0;
        end
        else 
        begin
            case (uart_state_tx)
                UART_STATE_IDLE:
                begin
                    uartTxLine<=1;
                    if (startTx) 
                    begin
                        uartTxBusy<=1;
                        bit_index<=0;
                        // uart_state_tx<=UART_STATE_START;
                        uartTxLine<=0;
                        uart_state_tx<=UART_STATE_DATA;
                        //put odd/even parity based on parity input config
                        dataReg[DATA_BITS-1:0]<=dataTx;
                        dataReg[DATA_BITS]<=(parity)? ~(^dataTx):(^dataTx);
                    end
                end
                
                // UART_STATE_START: 
                // begin
                // end
                
                UART_STATE_DATA: 
                begin
                    if (bit_index<DATA_BITS+1)
                    begin
                        bit_index<=bit_index+1;
                        uartTxLine<=dataReg[bit_index];
                    end
                    else
                    begin
                        bit_index<=0;
                        uart_state_tx<=UART_STATE_STOP;
                        stop_counter<=0;
                        uartTxLine<=1;
                    end
                end
                
                //Single stop bit at the baud rate
                UART_STATE_STOP: 
                begin
                    if(stop_counter<(stopBits? 1:0))
                    begin
                        uartTxLine<=1;
                        stop_counter<=stop_counter+1;
                    end
                    else
                    begin
                        // //streaming option without intermediate idle states
                        // if(startTx)
                        // begin
                        //     uart_state_tx<=UART_STATE_START;
                        // end
                        // else
                        begin
                            uartTxBusy<=0;
                            stop_counter<=0;
                            uart_state_tx<=UART_STATE_IDLE;                            
                        end
                    end
                end
                
                default: uart_state_tx<=UART_STATE_IDLE;
            endcase
        end
    end
endmodule


`endif //UART_TX_H