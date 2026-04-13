#include <iostream>

#include "uart_core_tx_tests.hpp"
#include "uart_core_reg_mem.hpp"
// #include "uart_core_rand.hpp"

//Ctor
UartCoreTxTest::UartCoreTxTest()
{
	m_top=new Vuart_core;
	m_vcd=new VerilatedVcdC;

    m_top->trace(m_vcd,99);
    m_vcd->open("dump.vcd");

	m_timestamp=0;
	m_clkCycles=0;

	//init module
	m_top->sysClk=0;
	m_top->nRst=1;
	this->reset();
}

//Dtor
UartCoreTxTest::~UartCoreTxTest()
{
	m_vcd->close();

	delete m_top;
	delete m_vcd;
}

//Private methods
void UartCoreTxTest::writeReg(uint32_t addr,uint32_t data)
{
	m_top->addrIn=addr;
	m_top->dataIn=data;
	m_top->wr=1;
	this->tick();
	m_top->wr=0;
}

uint32_t UartCoreTxTest::readReg(uint32_t addr)
{
	m_top->addrIn=addr;
	m_top->wr=0;
	this->tick();
	return m_top->dataOut;
}

//Public methods
void UartCoreTxTest::reset()
{
	m_top->nRst=0;
	m_top->eval();
	m_top->nRst=1;
	m_top->eval();
}

void UartCoreTxTest::tick()
{
	m_top->sysClk=!m_top->sysClk;
	m_top->eval();
	m_vcd->dump(m_timestamp);
	m_timestamp++;

	m_top->sysClk=!m_top->sysClk;
	m_top->eval();
	m_vcd->dump(m_timestamp);
	m_timestamp++;

	m_clkCycles++;

	m_rxMonitor.observe((uint32_t)m_top->uartTxLine);
}

void UartCoreTxTest::setConfig(uint32_t config)
{
	//cannot change config while uart is busy
	while(this->readReg(UART_REG_STATUS)!=0);
	this->writeReg(UART_REG_CONFIG,config);
	m_config=config;
	P_BAUD_CYCLE=m_config&0x0000FFFF;
	// std::cout<<"Baud cycles"<<P_BAUD_CYCLE<<"\n";

	m_rxMonitor.setConfig(P_BAUD_CYCLE);
}

void UartCoreTxTest::sendByte(uint8_t byte,bool stream)
{
	uint32_t data=(uint32_t) byte;
	while(this->readReg(UART_REG_STATUS)!=0);
	this->writeReg(UART_REG_WRITE,data);
	this->writeReg(UART_REG_CONTROL,1);	//send 1 for starting transmission

	if(stream)
		this->runUntilEOF();
	else
	{
		this->readReg(UART_REG_STATUS);
		this->runUntilTxFree();
	}
}

void UartCoreTxTest::sendBytes(uint8_t* bytes,uint32_t size)
{
	for(uint32_t i=0;i<size;i++)
	{
		this->sendByte(bytes[i],true);
		this->m_sentBytes.push_back(bytes[i]);
	}
}

void UartCoreTxTest::sendBytesV(std::vector<uint8_t> bytes)
{
	for(uint32_t i=0;i<bytes.size();i++)
	{
		this->sendByte(bytes[i],true);
		this->m_sentBytes.push_back(bytes[i]);
	}
}

void UartCoreTxTest::runUntilEOF()
{
	int stopBits=((m_config>>(1+3+16))&1)+1;
	int OVERSAMPLING=(1<<(m_config>>16)&7);
	// std::cout<<"OS"<<OVERSAMPLING<<"\n";
	// std::cout<<stopBits<<"\n";
	uint32_t stopCycle=m_clkCycles+((OVERSAMPLING*P_BAUD_CYCLE)*(1+8+1+stopBits));
	// std::cout<<"m_clkCycles"<<m_clkCycles<<"stopCycle"<<stopCycle<<"\n";
	
	while(m_clkCycles<=stopCycle)
		tick();
}

void UartCoreTxTest::runUntilTxFree()
{
	while(this->readReg(UART_REG_STATUS)!=0);
}


void UartCoreTxTest::compare()
{
	if(this->m_sentBytes.size()!=m_rxMonitor.m_received.size())
	{
		std::cout<<"Mismatch in sent and received bytes\n";
	}
	else
	{
		for(unsigned int i=0;i<m_sentBytes.size();i++)
		{
			if(m_sentBytes[i]==m_rxMonitor.m_received[i])
				std::cout<<"CASE "<<i<<": PASSED\n";
			else
				std::cout<<"CASE "<<i<<": FAILED\n";
		}
	}
}

//SimUartCoreRx
//Ctor
// SimUartCoreRx(uint32_t bitDuration,uint32_t config)
// {
// 	m_bitDuration=bitDuration;
// 	m_config=config;
// 	m_parity=(m_config>>(16+30))&1;
// 	m_stopBits=(m_config>>(16+3+1))&1;
// 	m_prevValue=1;
// 	m_rxActive=false;
// }

// //Dtor
// ~SimUartCoreRx()
// {

// }

// void run(uint32_t timestamp,int txLine)
// {

// }