MAKEFILE_INCL ?= 
include build_makefiles/$(MAKEFILE_INCL)

SRC_FILES := $(wildcard $(DIR_PATH)/verilator_sim/src/$(SRC_PREFIX)*.cpp)
SRC_FILES_PREFIX := $(addprefix ../../,$(SRC_FILES))

OBJ_DIR := obj_dir/$(TOP)


$(info TOP='$(TOP)')
$(info DIR_PATH='$(DIR_PATH)')
$(info SRC_PREFIX='$(SRC_PREFIX)')
$(info PATTERN='$(DIR_PATH)/verilator_sim/src/$(SRC_PREFIX)*.cpp')
$(info SRC_FILES='$(SRC_FILES)')


# generate verilator sources
verilate:
	@echo "Compiling $(SRC_FILES)"
	verilator \
	-Wall $(VERILATOR_WARNING_IGNORE) \
	--report-unoptflat \
	$(VERILATOR_DEFINES_FLAGS) \
	-CFLAGS "-I../../$(DIR_PATH)/verilator_sim/include" \
	--cc $(DESIGN_FILES) \
	--top-module $(TOP) \
	-I$(DIR_PATH) \
	-Mdir $(OBJ_DIR) \
	--exe $(SRC_FILES_PREFIX) \
	--trace

# VERILATOR_ROOT_INC is from .bashrc
# build design
build:
	make -C obj_dir/$(TOP) -f V$(TOP).mk \
	CXXFLAGS+="-I$(VERILATOR_ROOT_INC) -I." \
	CPPFLAGS+="-I../../$(DIR_PATH)/verilator_sim/include"

# run design
run:
	cd obj_dir/$(TOP) && ./V$(TOP) && cd ../..

build-run:
	$(MAKE) build
	$(MAKE) run

# cleanup
clean:
	rm -rf obj_dir/$(DESIGN)/