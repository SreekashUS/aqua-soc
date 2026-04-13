#include "uart_core_rand.hpp"

UartCoreTxRandSeq::UartCoreTxRandSeq()
{

}
UartCoreTxRandSeq::~UartCoreTxRandSeq()
{

}


void UartCoreTxRandSeq::setSeed(uint32_t seed)
{
	srand(seed);
}

std::vector<uint8_t> UartCoreTxRandSeq::genData(uint32_t size)
{
	std::vector<uint8_t> temp;
	for(unsigned int i=0;i<size;i++)
		temp.push_back(rand()%255);
	return temp;
}