TOP:= mmio_dev
DESIGN_FILES:= \
	peripherals/uart/rtl/uart_core.v \
	peripherals/uart/rtl/uart_tx.v \
	peripherals/uart/rtl/baud_generator_int.v \
	peripherals/uart/rtl/uart_rx.v \
	peripherals/uart/rtl/uart_rx_oversampler.v \
	tests/verilator/uart/mmio_dev.v

DIR_PATH:= peripherals/uart

# mention source files and include directly
SRC_FILES:= \
	commons/src/sim_clock.cpp \
	mmio/src/mmio_driver.cpp \
	uart/src/uart_sequence.cpp \
	uart/src/uart_tb.cpp
SRC_INCLUDES:= \
	"-Itests/verilator/"

# Verilator defines, passed as Makefile variable, e.g.,
# make verilate VERILATOR_DEFINES="UART_BAUD=115200 ENABLE_LOG"
VERILATOR_DEFINES ?=
VERILATOR_DEFINES_FLAGS := $(addprefix -D,$(VERILATOR_DEFINES))

VERILATOR_WARNINGS:=no-UNUSED no-UNDRIVEN
VERILATOR_WARNING_IGNORE := $(addprefix -W,$(VERILATOR_WARNINGS))