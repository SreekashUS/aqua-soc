import reg_map::*;
class uart_cfg_write_seq extends uart_base_seq;

	`uvm_object_utils(uart_cfg_write_seq)

	function new(string name="uart_cfg_write_seq");
	  super.new(name);
	endfunction

	task body();
		super.body();

      	//enable tx datapath
      	writeReg(UART_REG_CONTROL,32'h0028_0000);
		//write config
		writeReg(UART_REG_CONFIG,32'h0000_0002);
		//write byte
		writeReg(UART_REG_WRITE,32'h0000_00AA);
	endtask :body

endclass :uart_cfg_write_seq