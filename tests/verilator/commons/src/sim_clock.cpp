#include "commons/include/sim_clock.hpp"

SimClock::SimClock()
{

}

SimClock::~SimClock()
{

}

void step()
{
	m_drv->m_top->sysClk=!m_drv->m_top->sysClk;
	m_drv->eval();

	m_drv->m_top->sysClk=!m_drv->m_top->sysClk;
	m_drv->eval();

	cycle++;
}