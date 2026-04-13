#ifndef UART_CORE_TX_TESTS_HPP
#define UART_CORE_TX_TESTS_HPP

/**
 * Tests done:
 * 1. tx transmit and receive (comparison)
 * 2. multiple baud rates (comparison with baud rates and system clock)
 */

#include <vector>
#include <random>

#include "verilated_vcd_c.h"
#include "verilated.h"

#include "Vuart_core.h"

typedef struct rx_packet_info
{
	uint8_t data;	//received data
	bool valid;		//valid
	uint8_t error;	//type of error=>parity, frame error etc
}rxPacket;

// class SimUartCoreRx
// {
// private:
// 	uint32_t m_sampleTx;
// 	uint32_t m_bitDuration;
// 	uint32_t m_config; //for stop bits, baud rate etc
// 	uint32_t m_stopBits;
// 	uint32_t m_parity;
	
// 	int m_prevValue;
// 	uint32_t m_prevTimestamp;
	
// 	bool m_rxActive;
// 	uint8_t m_byteReceived;

// public:
// 	SimUartCoreRx(uint32_t bitDuration,uint32_t config);
// 	~SimUartCoreRx();

// 	void run(uint32_t timestamp,int txLine);
// };

class UartRxModel 
{
public:
    enum State {IDLE,START,DATA,STOP};

    State m_state=IDLE;

    uint32_t baud_counter=0;
    uint32_t bit_index=0;

    uint8_t rx_byte=0;

    uint32_t BAUD_TICKS;          // sysClk cycles per bit (configured)
    uint32_t MID_SAMPLE;          // BAUD_TICKS / 2

    std::vector<uint8_t> m_received;

    UartRxModel(){}

    UartRxModel(uint32_t baud_ticks)
        : BAUD_TICKS(baud_ticks),
          MID_SAMPLE(baud_ticks / 2){}

    void setConfig(uint32_t config) 
    {
    	BAUD_TICKS=config&0x0000FFFF;
    	MID_SAMPLE=BAUD_TICKS/2;
    }

    void observe(uint32_t tx) 
    {
        switch (m_state) 
        {
        case IDLE:
            // start bit detected
            if(tx==0) 
            { 
                m_state=START;
                baud_counter=0;
            }
            break;

        case START:
            baud_counter++;

            // confirm valid start bit at mid point
            if(baud_counter==MID_SAMPLE) 
            {
                if (tx != 0) {
                    m_state=IDLE; // false start
                }
            }

            if(baud_counter>=BAUD_TICKS) 
            {
                m_state=DATA;
                baud_counter=0;
                bit_index=0;
                rx_byte=0;
            }
            break;

        case DATA:
            baud_counter++;

            if(baud_counter==MID_SAMPLE) 
            {
                // sample bit
                rx_byte |= (tx << bit_index);
            }

            if(baud_counter>=BAUD_TICKS) 
            {
                baud_counter=0;
                bit_index++;

                if(bit_index==8) 
                {
                    m_state=STOP;
                }
            }
            break;

        case STOP:
            baud_counter++;

            if(baud_counter==MID_SAMPLE) 
            {
                if(tx != 1) 
                {
                    // framing error (optional logging)
                }
            }

            if(baud_counter>=BAUD_TICKS) 
            {
                m_received.push_back(rx_byte);
                // std::cout<<"Received: "<<(int)rx_byte<<"\n";
                m_state=IDLE;
            }
            break;
        }
    }
};

class UartCoreTxTest
{
private:
	Vuart_core* m_top;	//design
	VerilatedVcdC* m_vcd; //vcd dump

	uint32_t m_clkCycles; //cycleCount for logging
	uint32_t m_timestamp; //timestamp for vcd
	uint32_t m_config; //config

	//write to reg
	void writeReg(uint32_t addr,uint32_t data);
	//read from reg
	uint32_t readReg(uint32_t addr);

	uint32_t P_BAUD_CYCLE;


	//Software receiver (monitor)
	UartRxModel m_rxMonitor;

	//internal record for scoreboard type checking with software rx model
	std::vector<uint8_t> m_sentBytes;
public:
	UartCoreTxTest();
	~UartCoreTxTest();

	//reset design
	void reset();

	//move design forward by 1 sysClk cycle
	void tick();

	//Similar to drivers
	//config uart tx
	void setConfig(uint32_t config);

	//send byte
	void sendByte(uint8_t byte,bool stream);

	//stream bytes
	void sendBytes(uint8_t* bytes,uint32_t size);

	//stream bytes via Vector
	void sendBytesV(std::vector<uint8_t> bytes);

	//run till end of UART frame
	void runUntilEOF();

	//run till tx is free (for streaming bytes)
	void runUntilTxFree();

	//Compare sent and received bytes
	void compare();
};

#endif //UART_CORE_TX_TESTS_HPP