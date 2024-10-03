`ifndef UARTTX_H
`define UARTTX_H

module uartTxMod
#(
	//BAUD rate=115200 and clock frequency=50MHz
    // parameter CLOCK_DIV=434
	//BAUD rate=921600 and clock frequency=50MHz
    parameter CLOCK_DIV=54
    ,parameter DATA_BITS=8
    ,parameter STOP_BITS=1
)
(
    input wire clk,rst,
    //startTx signal
    input wire startTx,
    //dataTx to be transmitted
    input wire [DATA_BITS-1:0] dataTx,
    //uartTx line
    output reg uartTx,
    //uartBusyTx
    output wire uartBusyTx
);
    reg [1:0] uart_state_tx;

    parameter BIT_INDEX=$clog2(DATA_BITS+1);
    reg [BIT_INDEX-1:0] bit_index;

    parameter CLK_BITS=$clog2(CLOCK_DIV);
    reg [CLK_BITS-1:0] clk_count;

    //UART uart_states
    localparam IDLE=0;
    localparam START=1;
    localparam DATA=2;
    localparam STOP=3;

    assign uartBusyTx=~(uart_state_tx==IDLE);

    //added for even parity
    reg [DATA_BITS-1+1:0] dataReg;

    always @(posedge clk,posedge rst) 
    begin
        if (rst) 
        begin
            uart_state_tx<=IDLE;
            uartTx<=1;
            clk_count<=0;
            bit_index<=0;
        end 
        else 
        begin
            case (uart_state_tx)
                IDLE:
                begin
                    uartTx<=1;
                    if (startTx) 
                    begin
                        bit_index<=0;
                        uart_state_tx<=START;
                    end
                end
                
                START: 
                begin
                    uartTx<=0;
                    clk_count<=0;
                    uart_state_tx<=DATA;
                    //put even parity bit within the dataReg
                    dataReg<={^dataTx,dataTx};
                end
                
                DATA: 
                begin
                    //Pulse generator for required Baud rate
                    if (clk_count<CLOCK_DIV-1) 
                    begin
                        clk_count<=clk_count+1;
                        //only for visual debug, causes dynamic power loss
                        // uartTx<=0;
                    end

                    //else send dataTx
                    else
                    begin
                        clk_count<=0;
                        if (bit_index<DATA_BITS+1)
                        begin
                            bit_index<=bit_index+1;
                        	uartTx<=dataReg[bit_index];
                        end
                        else
                        begin
                            bit_index<=0;
                            uart_state_tx<=STOP;
                        end
                    end
                end
                
                //Single stop bit at the baud rate
                STOP: 
                begin
                    uartTx<=1;
                    if(clk_count<=CLOCK_DIV-1)
                    begin
                        clk_count<=clk_count+1;
                        uart_state_tx<=STOP;
                    end
                    else
                        uart_state_tx<=IDLE;
                end
                
                default: uart_state_tx<=IDLE;
            endcase
        end
    end
endmodule

`endif //UARTTX_H