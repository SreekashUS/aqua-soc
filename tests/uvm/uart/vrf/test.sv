class uart_test extends uvm_test;

    `uvm_component_utils(uart_test)

    mmio_drv     drv;
    mmio_seqr    seqr;

    function new(string name="uart_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv  = mmio_drv::type_id::create("drv", this);
        seqr = mmio_seqr::type_id::create("seqr", this);

        if(!uvm_config_db#(virtual mmio_if)::get(this, "", "vif", drv.vif))
            `uvm_fatal("NOVIF","vif not set")

    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(seqr.seq_item_export);

    endfunction


    task run_phase(uvm_phase phase);
      
        uart_cfg_write_seq seq;

        phase.raise_objection(this);

        seq = uart_cfg_write_seq::type_id::create("seq");
      
        #3;

        seq.start(seqr);   // FULL UVM FLOW restored

        #100000;

        phase.drop_objection(this);

    endtask

endclass