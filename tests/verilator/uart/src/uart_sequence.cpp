#include <iostream>

#include "uart/include/uart_sequence.hpp"
#include "commons/regmaps/uart_reg_map.hpp"

UartSequence::UartSequence()
{

}

UartSequence::~UartSequence()
{

}

void UartSequence::setDriver(MmioDriver* drv)
{
	this->m_drv=drv;
}

void UartSequence::setSimClock(SimClock* simClk)
{
	this->m_sim_clk=simClk;
}

void UartSequence::setControl(uint8_t control)
{
	m_drv->writeReg(UART_REG_CONTROL,control);
	m_sim_clk->step();
	m_drv->invalidate();
}

void UartSequence::setConfig(uint32_t uartConfig)
{
	m_drv->writeReg(UART_REG_CONFIG,uartConfig);
	m_sim_clk->step();
	m_drv->invalidate();
}

void UartSequence::setInterruptMask(uint8_t mask)
{
	m_drv->writeReg(UART_REG_INT_MASK,mask);
	m_sim_clk->step();
	m_drv->invalidate();
}

void UartSequence::sendByte(uint8_t data)
{
	//write
	m_drv->writeReg(UART_REG_WRITE,(uint32_t)data);
	m_sim_clk->step();
	m_drv->invalidate();
}

//Add receive types as arg later: poll status, wait clk steps, etc
uint32_t UartSequence::recvByte()
{
	//Use interrupt register for receiving bytes
	m_drv->readReg(UART_REG_INT_MASK);
	m_sim_clk->step();
	uint8_t mask=m_drv->readReg(UART_REG_INT_MASK);
	
	//rx_ready interrupt enabled
	if(mask&1==1)
	{
		while(m_drv->readReg(UART_REG_INT_STATUS)==0)
		{
			m_sim_clk->step();
		}
		//clear interrupt W1C
		m_drv->writeReg(UART_REG_INT_CLR,(uint32_t)0x01);
		m_drv->readReg(UART_REG_READ);
		m_sim_clk->step();
		return (uint32_t)m_drv->readReg(UART_REG_READ);
	}
	else
	{
		std::cout<<"RX ready interrupt maskedn\n";
		return 0;
	}
}

void UartSequence::testLoopbackByteInterrupt(uint8_t byte)
{
	//set control and config
	setControl(0x07);
	setInterruptMask(0x01);

	sendByte(byte);

	//run until interrupt
	uint32_t bit_cycles=0;
	while(m_drv->m_top->intr==0)
	{
		m_sim_clk->step();

		if(bit_cycles==128)
			sendByte(0x56);
		bit_cycles++;
	}

	uint32_t read_data;
	
	m_drv->readReg(UART_REG_INT_STATUS);
	m_sim_clk->step();
	m_drv->invalidate();

	uint32_t intr_status=m_drv->readReg(UART_REG_INT_STATUS);
	m_drv->invalidate();
	
	if((intr_status&1)==1)
	{
		// m_drv->readReg(UART_REG_READ);
		// m_sim_clk->step();
		// m_drv->invalidate();

		read_data=m_drv->readReg(UART_REG_READ);
		m_sim_clk->step();
		m_drv->invalidate();

		//clear interrupt
		m_drv->writeReg(UART_REG_INT_CLR,0x01);
		m_sim_clk->step();
		m_drv->invalidate();
	}
}

void UartSequence::testLoopbackCont(std::vector<uint8_t> bytes)
{
	//set control and config
	setControl(0x07);
	setInterruptMask(0x01);

	unsigned int i=0;
	while(i<bytes.size())
	{
		sendByte(bytes[i]);
		// std::cout<<m_drv->ready()<<"\n";
		while(!m_drv->ready())
		{
			m_sim_clk->step();
		}
		i++;
	}
}


// void UartSequence::sendBytesV(std::vector<uint8_t> &data)
// {
// 	for(unsigned int i=0;i<data.size();i++)
// 	{
// 		sendByte(data[i]);
// 		while(m_drv->readReg(UART_REG_STATUS)&1==1)
// 		{
// 			m_sim_clk->step();	
// 		}
// 		m_sim_clk->step();
// 	}
// }

// void UartSequence::sendBytesLoopV(std::vector<uint8_t> &data)
// {
// 	//read config and enabled loopback
// 	m_drv->readReg(UART_REG_CONFIG);
// 	m_sim_clk->step();
// 	uint32_t config=m_drv->readReg(UART_REG_CONFIG);

// 	//finish later
// }