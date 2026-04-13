#ifndef UART_CORE_RAND
#define UART_CORE_RAND

/**
 * Placeholder class for generating random numbers
 * TODO:
 * features: 
 * 		1. basic constraints
 * 		2. distribution based generation (value_range:pct format)
 */

#include "Vuart_core.h"
#include <vector>
#include <random>

class UartCoreTxRandSeq
{
private:
	uint8_t* m_generatedData;
public:
	UartCoreTxRandSeq();
	~UartCoreTxRandSeq();

	//set seed for random sequence generator
	void setSeed(uint32_t seed);

	std::vector<uint8_t> genData(uint32_t size);
};

#endif //UART_CORE_RAND