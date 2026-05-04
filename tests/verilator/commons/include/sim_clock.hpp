#pragma once

#include "verilated_vcd_c.h"

#include "mmio/include/mmio_driver.hpp"

class SimClock 
{
private:
	MmioDriver* m_drv;
    VerilatedVcdC* m_vcd;
    uint64_t m_timestamp;
public:
    uint64_t cycle = 0;

    SimClock(VerilatedVcdC* vcdRef);
    ~SimClock();

    void setDrv(MmioDriver* drv)
    {
		this->m_drv=drv;
    }

    void step();
};