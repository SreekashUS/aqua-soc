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
}

void UartSequence::setConfig(uint32_t uartConfig)
{
	m_drv->writeReg(UART_REG_CONFIG,uartConfig);
	m_sim_clk->step();
}

void UartSequence::sendByte(uint8_t data,uint8_t control,uint32_t config)
{
	//set control and config
	setControl(control);
	setConfig(config);

	//write
	m_drv->writeReg(UART_REG_WRITE,(uint32_t)data);
	m_sim_clk->step();
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