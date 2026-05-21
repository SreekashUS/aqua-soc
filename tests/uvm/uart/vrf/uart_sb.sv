import reg_map::*;

class uart_sb extends uvm_scoreboard;

    `uvm_component_utils(uart_sb)

    //written by mmio_mon
    uvm_analysis_imp #(mmio_txn,uart_sb) imp;

    mmio_txn tx_q[$];
    mmio_txn rx_q[$];

    //scoreboard counts
    int unsigned tx_count=0;
    int unsigned rx_count=0;
    int unsigned pass=0;
    int unsigned fail=0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp=new("imp", this);
    endfunction

    // single stream entry point split into write/read queues
    function void write(mmio_txn tr);
        if(tr.is_wr)
        begin
            if(tr.addr==UART_REG_WRITE)
            begin
                tx_q.push_back(tr);
                tx_count=tx_count+1;
            end
        end
        else
        begin
            if(tr.addr==UART_REG_READ)
            begin
                rx_q.push_back(tr);
                rx_count=rx_count+1;
            end
        end
    endfunction

    task run_phase(uvm_phase phase);
        mmio_txn rx;
        bit found;

        forever
        begin
            //decay cleanup tx
            //run loop for tx
            //if tx.time>timeout delete from queue

            wait(rx_q.size()>0);
            rx=rx_q.pop_front();
            found=0;

            //search the window
            for(int i=0;i<tx_q.size();i=i+1)
            begin
              if(tx_q[i].data==rx.data)
                begin
                    found=1;
                    break;
                end
            end
            //print
            if(found)
            begin
                `uvm_info("UART Tx/Rx received",$sformatf("passed: rx=%0h",rx.data), UVM_MEDIUM)
                pass=pass+1;
            end
            else
            begin
                `uvm_info("UART Tx/Rx not received",$sformatf("failed: rx=%0h",rx.data), UVM_MEDIUM)
                fail=fail+1;
            end
        end
    endtask

    //UVM-1.2 report phase is a function
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("UART_STATS",$sformatf("TX=%0d RX=%0d PASS=%0d FAIL=%0d",tx_count, rx_count, pass, fail),UVM_LOW)
    endfunction :report_phase
endclass