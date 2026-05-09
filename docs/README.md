# SoC documentation

# Current status:
## IP level implementations
### UART (Core)
UART Core IP is implemented as a standard MMIO register interface IP with basic peripheral commands and is verified 
in parallel with respective UVM framework and verilator framework(for fast debug)

Read [UART Core documentation](peripherals/uart/core/README.md)