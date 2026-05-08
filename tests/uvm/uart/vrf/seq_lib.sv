import reg_map::*;

class uart_write_seq extends uart_base_seq;
    `uvm_object_utils(uart_write_seq)

    bit [7:0] addr;
    bit [31:0] data;

    function new(string name="uart_write_seq");
        super.new(name);
    endfunction
  
    task body();
        mmio_txn tx_wr=mmio_txn::type_id::create("tx_wr");

        start_item(tx_wr);
            tx_wr.addr=addr;
            tx_wr.data=data;
            tx_wr.is_wr=1;
        finish_item(tx_wr);
    endtask
endclass :uart_write_seq


class uart_read_seq extends uart_base_seq;
    `uvm_object_utils(uart_read_seq)

    bit [7:0] addr;
    bit [31:0] data;

    function new(string name="uart_read_seq");
        super.new(name);
    endfunction
  
    task body();
        mmio_txn tx_rd=mmio_txn::type_id::create("tx_rd");

        start_item(tx_rd);
            tx_rd.addr=addr;
            tx_rd.data=data;
            tx_rd.is_wr=0;
        finish_item(tx_rd);

        data=tx_rd.data;
    endtask
endclass :uart_read_seq

class uart_cfg_seq extends uart_base_seq;
    rand bit [31:0] cfg;
  
    constraint cfg_baud {
      cfg[15:0] inside {[2:16'hFFFF]};
    }
  
  function new(string name="uart_cfg_seq");
        super.new(name);
    endfunction

    task body();
        uart_write_seq wr;
        
        assert(randomize());
          
        wr=uart_write_seq::type_id::create("wr");
        wr.addr=UART_REG_CONFIG;
        wr.data=cfg;
        wr.start(m_sequencer);
    endtask
endclass :uart_cfg_seq
