# UART CHANGELOG

## v0.1.0

Initial working baseline of UART IP with basic TX/RX functionality and MMIO interface.

### Added
- Basic UART RTL implementation (TX and RX datapaths)
- Memory-mapped register interface (MMIO)
- Initial register map definition
- Configurable baud generator integration
- Control integration (TX/RX enable and soft reset)

### Fixed
- Fixed incorrect reset signal wiring in UART core integration