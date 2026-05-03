package reg_map;

localparam logic [7:0] UART_REG_WRITE 		 	=8'h00;
localparam logic [7:0] UART_REG_READ		 	=8'h04;
localparam logic [7:0] UART_REG_CONFIG		 	=8'h08;
localparam logic [7:0] UART_REG_CONTROL			=8'h0C;
localparam logic [7:0] UART_REG_STATUS		 	=8'h10;
localparam logic [7:0] UART_REG_INT_STATUS		=8'h14;
localparam logic [7:0] UART_REG_INT_MASK  		=8'h18;
localparam logic [7:0] UART_REG_INT_PEND 		=8'h1C;
localparam logic [7:0] UART_REG_INT_CLR 		=8'h20;
localparam logic [7:0] UART_REG_END 			=8'h24;

endpackage : reg_map