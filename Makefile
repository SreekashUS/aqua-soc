VERILATOR_TEST_PATH:= tests/verilator

MAKEFILE_INCL ?= 
include $(VERILATOR_TEST_PATH)/build_makefiles/$(MAKEFILE_INCL)

SRC_FILES_PREFIX := $(addprefix ../../,$(SRC_FILES))

OBJ_DIR := $(VERILATOR_TEST_PATH)/obj_dir/$(TOP)

$(info TOP='$(TOP)')
$(info DIR_PATH='$(DIR_PATH)')
$(info SRC_PREFIX='$(SRC_PREFIX)')
$(info SRC_FILES_PREFIX='$(SRC_FILES_PREFIX)')

# generate verilator sources
verilate:
	@echo "Compiling $(SRC_FILES_PREFIX)"
	verilator \
	-Wall $(VERILATOR_WARNING_IGNORE) \
	--report-unoptflat \
	$(VERILATOR_DEFINES_FLAGS) \
	-CFLAGS $(SRC_INCLUDES) \
	--cc $(DESIGN_FILES) \
	--top-module $(TOP) \
	-I$(DIR_PATH) \
	-Mdir $(OBJ_DIR) \
	--exe $(SRC_FILES_PREFIX) \
	--trace

# VERILATOR_ROOT_INC is from .bashrc
# build design
build:
	make -C tests/verilator/obj_dir/$(TOP)/ -f V$(TOP).mk \
	CXXFLAGS+="-g -I$(VERILATOR_ROOT_INC) -I." \
	CPPFLAGS+="-I../../"

# run design
run:
	cd tests/verilator/obj_dir/$(TOP) && ./V$(TOP) && cd ../../../

# build and run
build-run:
	$(MAKE) build
	$(MAKE) run

# cleanup
clean:
	rm -rf tests/verilator/obj_dir/$(DESIGN)/