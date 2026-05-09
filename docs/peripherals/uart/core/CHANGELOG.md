# CHANGELOG

## v0.2.0
### RTL
#### Fixed
1. Fixed IRQ latching issue until read is issued on `UART_REG_INT_STATUS` register.
2. Fixed test mode (loopback) activation via `UART_REG_CONTROL` register.


### UVM
#### Added (`16fc311`)
1. Added MMIO agent, driver, interface, sequencer, transaction classes for generic MMIO reuse
2. Added base sequence, minimal sequence library containing read, write, write_cfg and flow sequences.
3. Added flow sequence with configurable operation count that is modified from test class. Flow sequence also supports
interrupt handling in case of an irq event triggered by UART
4. Added UART specific irq monitor and irq subscriber that triggers irq_event which is used by flow sequence to do IRQ subroutine (Similar to CPU process: read Interrupt status, if rx_ready then read received data)
5. Added `tb_pkg.sv` for maintaining compilation order and reusing the package later for complex environments
6. Added `base_test` and `write_read_irq_test` for testing the DUT.

#### Fixed (`e38b4fe`)
1. Fixed driver read delay by 1 cycle.
2. Updated control sequence with updated register bits from UART core.


## v0.1.0

### RTL
Initial working baseline of UART IP with basic TX/RX functionality and MMIO interface.

#### Added
- Basic UART RTL implementation (TX and RX datapaths)
- Memory-mapped register interface (MMIO)
- Initial register map definition
- Configurable baud generator integration
- Control integration (TX/RX enable and soft reset)

#### Fixed
- Fixed incorrect reset signal wiring in UART core integration