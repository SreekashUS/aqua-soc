#ifndef MMIO_DRIVER_HPP
#define MMIO_DRIVER_HPP

#include <cstdint>
#include "Vmmio_dev.h"

class MmioDriver 
{
public:
	Vmmio_dev* m_top;

	MmioDriver();
    ~MmioDriver();

	void setDut(Vmmio_dev* dut);
    
    void reset(bool value);
    void writeReg(uint32_t addr, uint32_t data);
    void invalidate();
    bool ready();
    uint32_t readReg(uint32_t addr);
    void eval();
};

#endif //MMIO_DRIVER_HPP