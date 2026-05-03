# UART Core
## Overview
This part of the SoC project implements a simple configurable UART (Universal Asynchronous Receiver Transmitter) IP core in verilog. The focus is primarily on RTL synthesizable design, well defined FSM and verification in both verilator(fast debug during RTL) and UVM(comprehensive tests).

## Features
1. Generic 8-bit transmission of data along with configurable parity(even/odd) and stop bits(1,2).
2. Configurable 16-bit integer baud generator which is used to generate baud clk for both TX and RX components of IP core with consideration of oversampling for Rx.
3. Control register designed for enabling TX, RX, test mode (Used for loopback tests with RX component) and soft reset capability
4. Memory mapped register interface (MMIO) for easier integration into SoC level environments.

## Supported behaviour
1. Write requests to configuration and control registers are silently dropped (not queued and not acknowledged) while TX/RX is busy.
2. TX and RX components support independent soft reset via `UART_REG_CONTROL`. 
System-wide hard reset resets all UART state machines and registers to default state.

## Design
UART core is split into 3 parts(4 parts if MMIO logic is considered):
- baud_generator_int (shared clock generator for TX and RX with oversampling)
- uart_tx (TX component that handles sending bytes)
- uart_rx (RX component that handles receiving bytes)
	- uart_rx_oversampler (oversampler does oversampling of middle 3 bits to filter out noise)

_Note: MMIO logic is generic and implemented as register decode model executions based on defined register map and access properties_

UART CORE design:
<p align="center">
  <img src="assets/uartCoreDesign.png" alt="uartCoreDesign" />
</p>

## Register map
This is the register map defined for MMIO access and used commonly in rtl and verification environments.

| register | register address | properties | usage |
|----------|------------------|------------|-------|
| UART_REG_WRITE/UART_REG_BASE | 0x00 | w only | base alias/write register for uart TX component to send data |
| UART_REG_READ | 0x04 | r only | read register for reading data from uart RX component |
| UART_REG_CONFIG | 0x08 | w only | config register for adjusting baud rate relative to sysClk and setting other config such as stop bits and parity |
| UART_REG_CONTROL | 0x0C | w only | control register to enable/disable TX/RX and soft reset TX/RX via MMIO interface |
| UART_REG_STATUS | 0x10 | r only | used by external device to poll status or read errors or busy components |
| UART_REG_INT_STATUS | 0x14 | r only | interrupt status register for listing all interrupts received |
| UART_REG_INT_MASK | 0x18 | w only | interrupt mask used by external device to enable specific interrupts |
| UART_REG_INT_PEND | 0x1C | r only | currently pending interrupts (unmasked by external device and active) |
| UART_REG_INT_CLR | 0x20 | w only | interrupt clear register after handling of interrupts (w1c-write 1 to clear) |
| UART_REG_END | 0x24 | none | reference for end of UART core register map |

### Planned features (Not in current release)
These features are not implemented in this release and may evolve before introduction:
1. FIFO support
2. DMA interface (high speed UART)