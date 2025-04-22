`ifndef I2CTX_H
`define I2CTX_H

module i2cTx
#(
	parameter ADDR_BITS=7
	,parameter DATA_BITS=8
)
(
	input wire clk,rst
	,input wire startTx
	,input wire [ADDR_BITS-1:0] addrTx
	,input wire [DATA_BITS-1:0] dataTx
	,input wire cont
	,output reg sda
	,output reg sclk
	,output wire i2cBusy
	,output wire deviceSel
);
	//state reg
	reg [3:0] i2c_state_tx;

    //i2c states
    localparam IDLE			=0;
    localparam START 		=1;
    localparam ADDR 		=2;
    localparam ADDR_ACK 	=3;
    localparam DATA 		=4;
    localparam DATA_ACK 	=5;
    localparam STOP 		=6;
    localparam DONE 		=7;
    localparam REPEAT_START =8;

    assign i2cBusy=~(i2c_state_tx==IDLE);

    always @(posedge clk,posedge rst)
    begin
    	if(rst)
    	begin
    		i2c_state_tx<=IDLE;
    		sda<=1;
    		sclk<=1;
    	end
    	else
    	begin
    		case(i2c_state_tx)
				IDLE:
				begin
					i2c_state_tx<=(startTx)? START:IDLE;
					sda<=1;
				end
				START:
				begin
					sda<=0;
				end
				ADDR:
				begin
					
				end
				ADDR_ACK:
				DATA:
				DATA_ACK:
				STOP:
				DONE:
				REPEAT_START:
				default:
    		endcase
    	end
    end

endmodule

`endif //I2CTX_H