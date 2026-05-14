class uart_flow_seq extends uart_base_seq;
    uvm_event m_irq_event;

    `uvm_object_utils(uart_flow_seq)

    int num_ops=16;
    int next_write_delay=1000;
    int current_write_cycle=0;
    // int reset_prob=10;
    // int cfg_prob=5;

    function new(string name="uart_flow_seq");
        super.new(name);
    endfunction

    task handle_irq();
        uart_read_seq rd;
        uart_write_seq wr;

        bit [31:0] status;
        bit [31:0] int_status;
        bit [31:0] rx_data;

        begin
            //interrupt handling
            if(m_irq_event!=null && m_irq_event.is_on())
            begin
                rd=uart_read_seq::type_id::create("irq_stat_rd");
                rd.addr=UART_REG_INT_STATUS;
                rd.start(m_sequencer);

                //rx ready interrupt
                if(rd.data[0])
                begin
                    rd=uart_read_seq::type_id::create("uart_rx_rd");
                    rd.addr=UART_REG_READ;
                    rd.start(m_sequencer);
                    rx_data=rd.data;
                    `uvm_info("RX received",$sformatf("IRQ RX=%0d", rx_data),UVM_MEDIUM)
                end

                //tx busy interrupt
                if(rd.data[3])
                begin
                    //if tx busy set wait timeout for next write
                    current_write_cycle=next_write_delay;
                end

                //Clear rx_ready interrupt
                wr=uart_write_seq::type_id::create("wr");
                wr.addr=UART_REG_INT_CLR;
                wr.data=32'h0000_0001;
                wr.start(m_sequencer);

                m_irq_event.reset();
            end
        end
    endtask :handle_irq

    task write_data();
        uart_write_seq wr;
        begin
            if(current_write_cycle==0)
            begin
                //write flow sequence 
                wr=uart_write_seq::type_id::create("wr");
                wr.addr=UART_REG_WRITE;
                wr.data=$urandom_range(0,255);
                wr.start(m_sequencer);
            end
            else
            begin
                current_write_cycle=current_write_cycle-1;
            end
        end
    endtask :write_data

    task body();
        //setup the UART, control, config, reset, set interrupt mask etc
        setup();

        //Do repeated transactions
        repeat (num_ops)
        begin
            handle_irq();

            write_data();
        end
    endtask

    task setup();
        uart_write_seq wr;

        //set baud config
        wr=uart_write_seq::type_id::create("wr");
        wr.addr=UART_REG_CONFIG;
        wr.data=32'h0000_0002;
        wr.start(m_sequencer);

        //enable tx, rx and loopback
        wr=uart_write_seq::type_id::create("wr");
        wr.addr=UART_REG_CONTROL;
        wr.data=32'h0000_0007;
        wr.start(m_sequencer);

        //enable tx interrupt
        wr=uart_write_seq::type_id::create("wr");
        wr.addr=UART_REG_INT_MASK;
        wr.data=32'h0000_0001;
        wr.start(m_sequencer);
    endtask

endclass