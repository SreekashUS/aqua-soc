class mmio_mon extends uvm_monitor;

	virtual mmio_if vif;
	uvm_analysis_port #(mmio_txn) ap;

	function new(string name="mmio_mon", uvm_component parent);
		super.new(name,parent);
		ap=new("ap",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#()::get(this, "", "mmio_if",vif))
			`uvm_fatal("NO VIF","no vif at mmio monitor")
	endfunction :build_phase

	task run_phase(uvm_phase phase);
		mmio_txn tr;

		forever
		begin
			@(posedge vif.clk);

			if(vif.valid)
			begin
				tr=mmio_txn::type_id::create("tr");

				tr.addr=vif.monitor.addr;
				tr.wdata=vif.monitor.wdata;
				tr.rdata=vif.monitor.rdata;
				tr.wr=vif.monitor.wr;

				ap.write(tr);
			end
		end
	endtask :run_phase

endclass :mmio_mon