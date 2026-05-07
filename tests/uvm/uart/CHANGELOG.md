# UART UVM CHANGELOG

## v0.2.0

### Added
1. Added MMIO agent, driver, interface, sequencer, transaction classes for generic MMIO reuse
2. Added UART specific base sequence, minimal sequence library containing read, write and write config sequences.
3. Added flow sequence with configurable operation count that is modified from test class. Flow sequence also supports
interrupt handling in case of a irq event triggered by UART
4. Added UART specific irq monitor and irq subscriber that triggers irq_event which is used by flow sequence to do IRQ subroutine (Similar to
CPU process: read Interrupt status, if rx_ready read received data)
5. Added `tb_pkg.sv` for maintaining compilation order and reusing the package later for complex environments
6. Added `base_test` and `write_read_irq_test` for testing the DUT.

## v0.1.0

Initial baseline for UVM UART (basic mmio interface)

### Added
- UVM code for basic tests
	- write configuration sequence