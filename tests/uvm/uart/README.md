# UART UVM

These files are used to test out basic UART core and tested out with working UVM supported simulator

## Tests supported
### Write and Read IRQ test
This test performs basic loopback write and read test using the interrupt signal.
In order for this test to work the DUT should be set to loopback mode via control register,
set to have valid baud rate divisor using config register and finally rx_ready interrupt should be enabled via 
interrupt mask register
- Set config
- Set control (tx-rx loopback enabled)
- Set interrupt for rx_ready (interrupt mask)
- Start flow sequence loop (count)
	- for each iteration
		- DUT sends IRQ signals when rx loopback is received
		- IRQ monitor puts data in IRQ subscriber port which triggers `irq_event` signal that notifies flow sequence
		interrupt handle
		- flow sequence interrupt handles the interrupt similar to a CPU reading interrupt
			- read interrupt status
			- decide interrupt handling based on bits set
			- read received data if rx_ready interrupt
			- clear processed interrupts (rx_read for now)


## To be added
- Scoreboard
- Coverage
- Virtual sequencer