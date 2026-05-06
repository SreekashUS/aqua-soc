class uart_base_seq extends uvm_sequence #(mmio_txn);

	`uvm_object_utils(uart_base_seq)

	function new(string name="uart_base_seq");
		super.new(name);
	endfunction : new

	task writeReg(input bit [7:0] addrIn, input bit [31:0] dataIn);
		mmio_txn tx_wr=mmio_txn::type_id::create("tx_wr");
		
		start_item(tx_wr);
			tx_wr.addr=addrIn;
			tx_wr.data=dataIn;
			tx_wr.is_wr=1;
		finish_item(tx_wr);
	endtask : writeReg

	task readReg(input bit [7:0] addrIn, output bit [31:0] dataOut);
		mmio_txn tx_rd=mmio_txn::type_id::create("tx_rd");

		start_item(tx_rd);
			tx_rd.addr=addrIn;
			tx_rd.is_wr=0;
		finish_item(tx_rd);

		dataOut=tx_rd.data;
	endtask

	task body();
		super.body();
	endtask : body

endclass : uart_base_seq