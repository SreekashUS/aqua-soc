`include "uvm_macros.svh"
import uvm_pkg::*;

class mmio_drv extends uvm_driver #(mmio_txn);

	`uvm_component_utils(mmio_drv)


	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new


	virtual mmio_if vif;
	//Gets vif from global config
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(virtual mmio_if)::get(this, "", "mmio_if",vif))
			`uvm_fatal("NOVIF","mmio_if not set")
	endfunction : build_phase


	//Converts transactions to DUT signals
	task run_phase(uvm_phase phase);
		mmio_txn req;

		vif.addr<=0;
		vif.wdata<=0;
		vif.wr<=0;

		forever
		begin
			seq_item_port.get_next_item(req);
			
			vif.valid<=1;
			vif.addr<=req.addr;
			vif.wdata<=req.data;
			vif.wr<=req.is_wr;

	        @(posedge vif.clk iff vif.ready iff vif.valid);

			// if (!req.is_wr)
			// 	req.data=vif.rdata;
			
			vif.valid<=0;

			vif.addr<=0;
			vif.wdata<=0;
			vif.wr<=0;
			
			seq_item_port.item_done();
		end
	endtask : run_phase

endclass : mmio_drv