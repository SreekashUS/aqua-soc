class uart_base_test extends uvm_test;

    `uvm_component_utils(uart_base_test)

    uart_env m_env;
    virtual mmio_if vif;

    function new(string name="uart_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual mmio_if)::get(this, "", "mmio_if",vif))
            `uvm_fatal("NO MMIO VIF","vif not set in uart_base_test")

        m_env=uart_env::type_id::create("m_env", this);
    endfunction

    //default override for uart tests
    task reset_phase(uvm_phase phase);
        phase.raise_objection(this);

        @(negedge vif.clk);
        vif.nRst<=0;

        vif.nRst<=0;
        repeat(5) @(posedge vif.clk);

        @(negedge vif.clk);
        vif.nRst<=1;

        phase.drop_objection(this);
    endtask
endclass