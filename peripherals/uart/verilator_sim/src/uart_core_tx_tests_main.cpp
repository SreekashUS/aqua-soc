// cpp standard libs
#include <iostream>

// vcd dump
#include "verilated_vcd_c.h"
#include "verilated.h"

#include "uart_core_rand.hpp"

#define UART_REG_BASE 0x40000000
#include "uart_core_tx_tests.hpp"

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    UartCoreTxTest test;

    //reset
    test.reset();
    
    //set UART config
    //8x oversampling config
    // test.setConfig(0x00080002);
    //16x oversampling config
    test.setConfig(0x00090002);

    //set interrupt mask
    test.setIntrMask(0x01);
    
    // // send a sample byte
    // test.sendByte(0x55,true);

    // send a custom sequence
    // uint32_t size=5;
    // uint8_t bytes[size]={0xAA,0xFF,0x3E,0x24,0x63};
    // // test.sendBytes(bytes,size);
    // test.sendAndLoopBack(bytes,size);

    // // Send a random generated sequence (seeded)
    UartCoreTxRandSeq sequenceGenerator;
    sequenceGenerator.setSeed(127);
    uint32_t samples=100;
    // test.sendBytesV(sequenceGenerator.genData(samples));
    test.sendAndLoopBackV(sequenceGenerator.genData(samples));

    // //compare bytes sent and received
    // test.compare();

    return 0;
}