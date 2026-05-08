`include "uvm_macros.svh"
import uvm_pkg::*;

class mmio_txn extends uvm_sequence_item;

  	rand bit [8-1:0] addr;
  	rand bit [32-1:0] data;
	rand bit is_wr;

	`uvm_object_utils(mmio_txn)

	function new(string name="mmio_txn");
		super.new(name);
	endfunction : new

	//printer utils(later)
endclass : mmio_txn