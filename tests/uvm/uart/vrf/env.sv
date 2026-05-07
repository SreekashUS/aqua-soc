class uart_env extends uvm_env;

    mmio_agent m_mmio_agent;
    irq_sub m_irq_sub;
    uart_irq_mon m_irq_mon;

    //handles from agents
    mmio_sqr m_sqr;
  
    uvm_event m_irq_event;

    `uvm_component_utils(uart_env)

    function new(string name="uart_env", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_mmio_agent=mmio_agent::type_id::create("m_mmio_agent", this);
        m_irq_sub=irq_sub::type_id::create("m_irq_sub", this);
        m_irq_mon=uart_irq_mon::type_id::create("m_irq_mon",this);
      
        m_irq_event=new("m_irq_event");
      
        uvm_config_db#(uvm_event)::set(this,"m_irq_sub","m_irq_event",m_irq_event);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        //connect irq monitor ap to subscriber
        m_irq_mon.ap.connect(m_irq_sub.imp);

        //uart_env.m_mmio_agent and irq have same sequencer
        m_irq_sub.m_sqr=m_mmio_agent.m_sqr;

        //attach handles to env
        m_sqr=m_mmio_agent.m_sqr;
    endfunction
endclass