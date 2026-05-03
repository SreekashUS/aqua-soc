module tb ;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;
    logic nRst;

    mmio_if vif(clk);

    logic intr;
    logic uartTxLine;
    logic uartRxLine;

    uart_core dut
    (
        .clk(clk)
        ,.nRst(nRst)

        ,.addrIn (vif.addr)
        ,.dataIn (vif.wdata)
        ,.dataOut(vif.rdata)
        ,.wr     (vif.wr)

        ,.intr(intr)
        ,.uartTxLine(uartTxLine)
        ,.uartRxLine(uartRxLine)
    );

    // clock
    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // reset
    initial 
    begin
        nRst = 0;
        #20;
        nRst = 1;
    end

    // UVM bootstrap
    initial 
    begin
        uvm_config_db#(virtual mmio_if)::set(null, "*", "vif", vif);
        run_test("uart_test");
    end

  
    initial
      begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
      end
endmodule