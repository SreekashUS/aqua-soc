#ifndef UART_CORE_REG_MAP_HPP
#define UART_CORE_REG_MAP_HPP

//define UART_REG_BASE map for integration tests as base address might vary
#ifndef UART_REG_BASE
	#define UART_REG_BASE			0xF0000000
#endif

#define UART_REG_WRITE 		 	UART_REG_BASE+0x00
#define UART_REG_READ		 	UART_REG_BASE+0x04
#define UART_REG_CONFIG		 	UART_REG_BASE+0x08
#define UART_REG_STATUS		 	UART_REG_BASE+0x0C
#define UART_REG_INT_STATUS		UART_REG_BASE+0x10
#define UART_REG_INT_MASK  		UART_REG_BASE+0x14
#define UART_REG_INT_CLR 		UART_REG_BASE+0x18
#define UART_REG_END 			UART_REG_BASE+0x1C

// status flag masking
#define UART_TX_BUSY  0
#define UART_RX_BUSY  1
#define UART_RX_READY 2

#endif //UART_CORE_REG_MAP_HPP