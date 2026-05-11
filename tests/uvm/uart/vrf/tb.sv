module tb;

    import uvm_pkg::*;
    import tb_pkg::*;
  
    `include "uvm_macros.svh"

    logic clk;
    logic nRst;

    //mmio_if encapsulated inside
    uart_if vif(clk);

    logic intr;
    logic uartTxLine;
    logic uartRxLine;

    uart_core dut
    (
        .clk(clk)
        ,.nRst(vif.m_mmio_if.nRst)

        ,.addrIn (vif.m_mmio_if.addr)
        ,.dataIn (vif.m_mmio_if.wdata)
        ,.dataOut(vif.m_mmio_if.rdata)
        ,.wr     (vif.m_mmio_if.wr)

        ,.intr(vif.irq)
        ,.uartTxLine(vif.tx)
        ,.uartRxLine(vif.rx)

        ,.valid(vif.m_mmio_if.valid)
        ,.busy(~vif.m_mmio_if.ready)
    );

    // clock
    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // reset and UVM
    initial 
    begin      
        vif.m_mmio_if.nRst = 0;
        #5;
        vif.m_mmio_if.nRst = 1;
    end
  
    initial
    begin
        //set db config components
        uvm_config_db#(virtual mmio_if)::set(null, "uvm_test_top.m_env.m_mmio_agent*", "mmio_if", vif.m_mmio_if);
        
        //to be used by rx driver and irq monitor
        uvm_config_db#(virtual uart_if)::set(null, "*", "uart_if", vif);
      
        run_test("uart_write_read_irq_test");    
    end
  
    initial
      begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
      end
endmodule