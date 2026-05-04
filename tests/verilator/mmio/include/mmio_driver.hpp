#ifndef MMIO_DRIVER_HPP
#define MMIO_DRIVER_HPP

template<typename DUT>
class MmioDriver 
{
public:
	DUT* m_top;

	MmioDriver();
    ~MmioDriver();

	void setDut(DUT* dut);
    
    void write(uint32_t addr, uint32_t data);
    uint32_t read(uint32_t addr);
    void eval();
};

#endif //MMIO_DRIVER_HPP