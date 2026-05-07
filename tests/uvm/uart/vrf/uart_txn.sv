`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_txn extends uvm_sequence_item;

	bit irq;
	bit tx;
	bit rx;

	`uvm_object_utils(uart_txn)

	function new (string name="uart txn");
		super.new(name);
	endfunction :new

endclass :uart_txn