#ifndef UART_SEQUENCE_HPP
#define UART_SEQUENCE_HPP

#include <vector>

#include "mmio/include/mmio_driver.hpp"
#include "commons/include/sim_clock.hpp"

class UartSequence
{
private:
	MmioDriver* m_drv;
	SimClock* m_sim_clk;
public:
	UartSequence();
	~UartSequence();

	void setDriver(MmioDriver* drv);
	void setSimClock(SimClock* simClk);

	void setControl(uint8_t control);

	void setConfig(uint32_t uartConfig);

	void setInterruptMask(uint8_t mask);

	void sendByte(uint8_t data);

	uint32_t recvByte();

	void testLoopbackByteInterrupt(uint8_t byte);

	void testLoopbackCont(std::vector<uint8_t> bytes);

	void sendBytesV(std::vector<uint8_t> &data);

	void sendBytesLoopV(std::vector<uint8_t> &data);
};

#endif //UART_SEQUENCE_HPP