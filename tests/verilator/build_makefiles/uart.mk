TOP:= mmio_dev
DESIGN_FILES:= \
	../$(TAG)/peripherals/uart/rtl/uart_core.v \
	../$(TAG)/peripherals/uart/rtl/uart_tx.v \
	../$(TAG)/peripherals/uart/rtl/baud_generator_int.v \
	../$(TAG)/peripherals/uart/rtl/uart_rx.v \
	../$(TAG)/peripherals/uart/rtl/uart_rx_oversampler.v \
	tests/verilator/uart/mmio_dev.v

DIR_PATH:= ../$(TAG)/peripherals/uart

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