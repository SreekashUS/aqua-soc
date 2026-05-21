qrun -batch \
     -coverage \
     -cover b \
     -access=rw+/. \
     -uvmhome uvm-1.2 \
     reg_map.svh tb_pkg.sv design.sv uart_tx.sv \
     uart_rx_oversampler.sv uart_rx.sv uart_engine.sv\
     baud_generator_int.sv irq_block.v if.sv uart_if.sv \
     testbench.sv \
     -timescale 1ns/1ns \
     -do "run -all; coverage exclude -srcfile testbench.sv; coverage exclude -srcfile tb_pkg.sv; coverage report -code b -details -output cov.txt; exit;"
#vlog -E flow_seq.sv

vcover report -details cov_0.ucdb > vcov.txt