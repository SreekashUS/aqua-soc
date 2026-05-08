import reg_map::*;

class irq_sub extends uvm_component;
    uvm_analysis_imp #(uart_txn, irq_sub) imp;

    mmio_sqr m_sqr;

    uvm_event m_irq_event;
  
    `uvm_component_utils(irq_sub)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp=new("imp", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(uvm_event)::get(this,"","m_irq_event",m_irq_event))
      begin
        `uvm_fatal("IRQ", "irq_event not set")
      end
    endfunction
  
    function void write(uart_txn t);
        if(t.irq)
        begin
            `uvm_info("IRQ_SUB", "IRQ detected -> triggering irq read", UVM_LOW)
            
            m_irq_event.trigger();
        end
    endfunction
endclass