class uart_irq_mon extends uvm_monitor;

    virtual uart_if vif;
    uvm_analysis_port #(uart_txn) ap;

    `uvm_component_utils(uart_irq_mon)

    function new(string name="uart_irq_mon",uvm_component parent);
        super.new(name,parent);
        ap=new ("ap",this);
    endfunction :new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

      if(!uvm_config_db#(virtual uart_if)::get(this, "", "uart_if",vif))
            `uvm_fatal("NO UART IF","uart_if not set for irq monitor")
    endfunction :build_phase

    task run_phase(uvm_phase phase);
        uart_txn tr;
        forever 
        begin
            //trigger only if interrupt happens
            @(posedge vif.irq);

            tr=uart_txn::type_id::create("intr_txn");
            tr.irq=1;
            tr.tx=vif.tx;
            tr.rx=vif.rx;

            ap.write(tr);
        end
    endtask

endclass