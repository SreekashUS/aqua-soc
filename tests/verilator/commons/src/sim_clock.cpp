#include "commons/include/sim_clock.hpp"

SimClock::SimClock(VerilatedVcdC* vcdRef)
{
	m_vcd=vcdRef;
	m_timestamp=0;
}

SimClock::~SimClock()
{

}

void SimClock::step()
{
	m_drv->m_top->clk=!m_drv->m_top->clk;
	m_drv->eval();
	m_vcd->dump(m_timestamp++);

	m_drv->m_top->clk=!m_drv->m_top->clk;
	m_drv->eval();
	m_vcd->dump(m_timestamp++);

	cycle++;
}