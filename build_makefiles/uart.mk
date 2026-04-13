TOP:= uart_core
DESIGN_FILES:= \
	peripherals/uart/uart_core.v \
	peripherals/uart/uart_tx.v \
	peripherals/uart/baud_generator_int.v
#	peripherals/uart/uart_rx.v \

DIR_PATH:= peripherals/uart

# mention source files and include directly
SRC_FILES:= \
	peripherals/uart/verilator_sim/src/uart_core_tx_tests.cpp \
	peripherals/uart/verilator_sim/src/uart_core_rand.cpp \
	peripherals/uart/verilator_sim/src/uart_core_tx_tests_main.cpp
SRC_INCLUDES:= \
	"-Iperipherals/verilator_sim/include"

# Verilator defines, passed as Makefile variable, e.g.,
# make verilate VERILATOR_DEFINES="UART_BAUD=115200 ENABLE_LOG"
VERILATOR_DEFINES ?=
VERILATOR_DEFINES_FLAGS := $(addprefix -D,$(VERILATOR_DEFINES))

VERILATOR_WARNINGS:=no-UNUSED no-UNDRIVEN
VERILATOR_WARNING_IGNORE := $(addprefix -W,$(VERILATOR_WARNINGS))