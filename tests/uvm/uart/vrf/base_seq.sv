class uart_base_seq extends uvm_sequence #(mmio_txn);

	`uvm_object_utils(uart_base_seq)

	function new(string name="uart_base_seq");
		super.new(name);
	endfunction :new

	task body();
		super.body();
	endtask :body

endclass :uart_base_seq