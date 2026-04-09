DIR_PATH ?= ./
DESIGN ?= design
OBJ_DIR := obj_dir/$(DESIGN)
TOP ?= 
SRC_PREFIX ?= src_files
SRC_FILES := $(wildcard $(DIR_PATH)/verilator_sim/src/$(SRC_PREFIX)*.cpp)

# Verilator defines, passed as Makefile variable, e.g.,
# make verilate VERILATOR_DEFINES="UART_BAUD=115200 ENABLE_LOG"
VERILATOR_DEFINES ?=
VERILATOR_DEFINES_FLAGS := $(addprefix -D,$(VERILATOR_DEFINES))

SRC_FILES_PREFIX := $(addprefix ../../,$(SRC_FILES))

# generate verilator sources
verilate:
	@echo "Compiling $(SRC_FILES)"
	verilator \
	-Wall -Wno-DECLFILENAME \
	$(VERILATOR_DEFINES_FLAGS) \
	-CFLAGS "-I../../$(DIR_PATH)/verilator_sim/include" \
	--cc $(DIR_PATH)/$(DESIGN).v \
	-I$(DIR_PATH) \
	-Mdir $(OBJ_DIR) \
	--exe $(SRC_FILES_PREFIX) \
	--trace

# VERILATOR_ROOT_INC is from .bashrc
# build design
build:
	make -C obj_dir/$(DESIGN) -f V$(DESIGN).mk \
	CXXFLAGS+="-I$(VERILATOR_ROOT_INC) -I." \
	CPPFLAGS+="-I../../$(DIR_PATH)/verilator_sim/include"

# run design
run:
	cd obj_dir/$(DESIGN) && ./V$(DESIGN) && cd ../..

# cleanup
clean:
	rm -rf obj_dir/$(DESIGN)/