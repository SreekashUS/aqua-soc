#pragma once
#include "Vuart_core.h"

template <typename DUT>
class SimClock 
{
private:
	MmioDriver<DUT>* m_drv;
public:
    uint64_t cycle = 0;

    SimClock();
    ~SimClock();

    void setDrv(MmioDriver<DUT>* drv)
    {
		this->m_drv=drv;
    }

    void step();
};