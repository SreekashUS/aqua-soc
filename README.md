# Aqua SoC
---
System on Chip(SoC) based on RISCV ISA with various requirements and &micro;-arch

# Getting started
---
- Starting with base RV32I instruction set which supports minimal program execution.

# Architectures
---
- Starting with RV32I (codename: `aqua_pygmy`)
	- Supports pipelined execution
	- [Has minimal execution unit ( `aluRv32i` )](./exec/alu/aluRv32i.v)
	- Register file of type 2R1W

## TODO
---
### AquaPygmy
- General:
	- Write Hazard logic
		- Data Hazards
		- Control Hazards
- For ASIC:
	- Synthesize proper `SRAM macro` for register file
- For FPGA:
	- Use `Embedded memory` or `BRAM` for register file with multiport access