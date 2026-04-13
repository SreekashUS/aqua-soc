// cpp standard libs
#include <iostream>

// vcd dump
#include "verilated_vcd_c.h"
#include "verilated.h"

#include "uart_core_rand.hpp"
#include "uart_core_tx_tests.hpp"

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    UartCoreTxTest test;

    //reset
    test.reset();
    
    //set UART config
    test.setConfig(0x00000002);
    
    // // send a sample byte
    // test.sendByte(0x55,false);

    // // send a custom sequence
    // uint32_t size=5;
    // uint8_t bytes[size]={0xAA,0xFF,0x3E,0x24,0x63};
    // test.sendBytes(bytes,size);
    

    // Send a random generated sequence (seeded)
    UartCoreTxRandSeq sequenceGenerator;
    sequenceGenerator.setSeed(127);
    uint32_t samples=100;
    test.sendBytesV(sequenceGenerator.genData(samples));

    //compare bytes sent and received
    test.compare();

    return 0;
}