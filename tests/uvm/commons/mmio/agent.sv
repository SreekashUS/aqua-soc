class mmio_agent extends uvm_agent;
	virtual mmio_if vif;

	mmio_drv m_drv;
	mmio_sqr m_sqr;
	mmio_mon m_mon;

  	`uvm_component_utils(mmio_agent)

	function new(string name="mmio_agent",uvm_component parent);
		super.new(name,parent);
	endfunction :new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(virtual mmio_if)::get(this, "", "mmio_if",vif))
			`uvm_fatal("NO MMIO VIF","No mmio_if created")

		m_drv=mmio_drv::type_id::create("m_drv",this);
		m_sqr=mmio_sqr::type_id::create("m_sqr",this);
		m_mon=mmio_mon::type_id::create("m_mon",this);
	endfunction :build_phase

	function void connect_phase(uvm_phase phase);
		m_drv.seq_item_port.connect(m_sqr.seq_item_export);
	endfunction :connect_phase
endclass :mmio_agent