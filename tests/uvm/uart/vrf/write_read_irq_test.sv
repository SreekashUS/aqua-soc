class uart_write_read_irq_test extends uart_base_test;

    `uvm_component_utils(uart_write_read_irq_test)

    function new(string name = "uart_smoke_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    //build, connect, reset phase are from base test

    task run_phase(uvm_phase phase);
        uart_flow_seq flow_seq;

        phase.raise_objection(this);

        `uvm_info(get_type_name(),"Starting UART flow sequence",UVM_LOW)

        // Create sequence
        flow_seq=uart_flow_seq::type_id::create("flow_seq");

        //parameters for test
        flow_seq.num_ops=32;

        //connect subscriber
        flow_seq.m_irq_event=m_env.m_irq_event;
      
        // Start on MMIO sequencer
        flow_seq.start(m_env.m_sqr);

        `uvm_info(get_type_name(),"UART flow sequence completed",UVM_LOW)

        #10000;

        phase.drop_objection(this);
    endtask
endclass