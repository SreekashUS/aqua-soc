build:
	iverilog -o temp.txt $(FILE)
run:
	vvp temp.txt
view:
	start gtkwave dump.vcd

restart:
	$(MAKE) build FILE=$(FILE)
	$(MAKE) run