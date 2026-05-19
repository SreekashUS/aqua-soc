class mmio_sqr extends uvm_sequencer #(mmio_txn);

  virtual mmio_if vif;
  
  `uvm_component_utils(mmio_sqr)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual mmio_if)::get(this, "", "mmio_if",vif))
      `uvm_fatal("NO VIF","No vif at mmio sequencer")
  endfunction :build_phase

endclass