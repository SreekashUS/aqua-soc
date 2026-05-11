#include "mmio/include/mmio_driver.hpp"

MmioDriver::MmioDriver()
{

}

MmioDriver::~MmioDriver()
{
	
}

void MmioDriver::reset(bool value)
{
	this->m_top->nRst=value? 0:1;
}

void MmioDriver::setDut(Vmmio_dev* dut)
{
	this->m_top=dut;
}

void MmioDriver::writeReg(uint32_t addr,uint32_t data)
{
	m_top->addrIn=addr;
	m_top->dataIn=data;
	m_top->wr=1;
	m_top->valid=1;
}

uint32_t MmioDriver::readReg(uint32_t addr)
{
	m_top->addrIn=addr;
	m_top->wr=0;
	// m_top->valid=
	return m_top->dataOut;
}

void MmioDriver::eval()
{
	m_top->eval();
}