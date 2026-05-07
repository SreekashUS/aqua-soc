qrun -batch -access=rw+/. -uvmhome uvm-1.2 reg_map.svh tb_pkg.sv design.sv uart_tx.sv uart_rx_oversampler.sv uart_rx.sv baud_generator_int.sv if.sv uart_if.sv testbench.sv -timescale 1ns/1ns -do "run -all; exit"

#vlog -E flow_seq.sv