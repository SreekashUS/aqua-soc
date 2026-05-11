// cpp standard libs
#include <iostream>
#include <vector>

// vcd dump
#include "verilated_vcd_c.h"
#include "verilated.h"

#define UART_REG_BASE 0x40000000

#include "commons/include/sim_clock.hpp"
#include "commons/regmaps/uart_reg_map.hpp"
#include "mmio/include/mmio_driver.hpp"
#include "uart/include/uart_sequence.hpp"

int main(int argc, char const *argv[])
{
	Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    Vmmio_dev* dut=new Vmmio_dev();
    VerilatedVcdC* vcd=new VerilatedVcdC;

    dut->trace(vcd,99);
    vcd->open("dump.vcd");

    //create mmio driver
    MmioDriver* dut_driver=new MmioDriver();
    dut_driver->setDut(dut);

    //create sim clock
    SimClock* sim_clk=new SimClock(vcd);
    sim_clk->setDrv(dut_driver);

    //reset for one cycle
    dut->nRst=1;
    sim_clk->step();
    dut->nRst=0;
    sim_clk->step();
    dut->nRst=1;

    //create sequence class for driving
    UartSequence uart_seq;

    //connect driver and simclock to sequence (acting as sequencer and test)
    uart_seq.setDriver(dut_driver);
    uart_seq.setSimClock(sim_clk);

    //sequence
    // uart_seq.sendByte(0xAA);

    //test loopback mode via polling interrupt
    // uart_seq.setConfig(0x00000002);
    // uart_seq.testLoopbackByteInterrupt(0xFF);

    //test loopback mode with ready handshake and interrupt reading

    std::vector<uint8_t> values={0xAA,0x55,0x26,0x84,0x53};

    uart_seq.setConfig(0x00000002);
    uart_seq.testLoopbackCont(values);

    uint32_t cycles=10000;
    while(cycles>0)
    {
        sim_clk->step();
        cycles--;
    }

    //cleanup
    delete dut;
    delete vcd;
}