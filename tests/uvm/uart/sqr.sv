class mmio_seqr extends uvm_sequencer #(mmio_txn);

  `uvm_component_utils(mmio_seqr)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass