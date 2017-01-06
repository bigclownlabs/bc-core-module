################################################################################
#   __  __       _         __ _ _                                              #
#  |  \/  | __ _| | _____ / _(_) | ___                                         #
#  | |\/| |/ _` | |/ / _ \ |_| | |/ _ \                                        #
#  | |  | | (_| |   <  __/  _| | |  __/                                        #
#  |_|  |_|\__,_|_|\_\___|_| |_|_|\___|                                        #
#                                                                              #
################################################################################

# TODO Implement "help" target

################################################################################
# Verbose build?                                                               #
################################################################################

ifeq ("$(BUILD_VERBOSE)","1")
Q :=
ECHO = @echo
else
MAKE += -s
Q := @
ECHO = @echo
endif

################################################################################
# Output name                                                                  #
################################################################################

OUT = firmware

################################################################################
# Output directory                                                             #
################################################################################

OUT_DIR = out

################################################################################
# Output extensions                                                            #
################################################################################

ELF = $(OUT_DIR)/$(OUT).elf
MAP = $(OUT_DIR)/$(OUT).map
BIN = $(OUT_DIR)/$(OUT).bin

################################################################################
# Linker script                                                                #
################################################################################

LD = sys/lkr/stm32l083cz.ld

################################################################################
# Include directories                                                          #
################################################################################

INC_DIR += app/inc
INC_DIR += bcl/inc
INC_DIR += bcl/stm/inc
INC_DIR += stm/hal/inc
INC_DIR += stm/usb/inc
INC_DIR += sys/inc

################################################################################
# Source directories                                                           #
################################################################################

SRC_DIR += app/src
SRC_DIR += bcl/src
SRC_DIR += bcl/stm/src
SRC_DIR += stm/hal/src
SRC_DIR += stm/usb/src
SRC_DIR += sys/src

################################################################################
# Toolchain                                                                    #
################################################################################

TOOLCHAIN = arm-none-eabi-
CC = $(TOOLCHAIN)gcc
OBJCOPY = $(TOOLCHAIN)objcopy
SIZE = $(TOOLCHAIN)size
OZONE = Ozone
DFU_UTIL = dfu-util

################################################################################
# Object files directory                                                       #
################################################################################

OBJ_DIR = obj

################################################################################
# Compiler flags for "c" files                                                 #
################################################################################

CFLAGS += -mcpu=cortex-m0plus
CFLAGS += -mthumb
CFLAGS += -mlittle-endian
CFLAGS += -std=c99
CFLAGS += -Wall
CFLAGS += -pedantic
CFLAGS += -Wextra
CFLAGS += -Wmissing-include-dirs
CFLAGS += -Wswitch-default
CFLAGS += -Wswitch-enum
CFLAGS += -D'__weak=__attribute__((weak))'
CFLAGS += -D'__packed=__attribute__((__packed__))'
CFLAGS += -D'USE_HAL_DRIVER'
CFLAGS += -D'STM32L083xx'
CFLAGS += -ffunction-sections
CFLAGS += -fdata-sections
CFLAGS_DEBUG += -g3
CFLAGS_DEBUG += -Og
CFLAGS_RELEASE += -Os

################################################################################
# Compiler flags for "s" files                                                 #
################################################################################

ASFLAGS += -mcpu=cortex-m0plus
ASFLAGS += -mthumb
ASFLAGS += -mlittle-endian
ASFLAGS_DEBUG += -g3
ASFLAGS_DEBUG += -Og
ASFLAGS_RELEASE += -Os

################################################################################
# Linker flags                                                                 #
################################################################################

LDFLAGS += -mthumb
LDFLAGS += -mlittle-endian
LDFLAGS += -mcpu=cortex-m0plus
LDFLAGS += -T$(LD)
LDFLAGS += -Wl,-lc
LDFLAGS += -Wl,-lm
LDFLAGS += -static
LDFLAGS += -Wl,-Map=$(MAP)
LDFLAGS += -Wl,--gc-sections
LDFLAGS += --specs=rdimon.specs
LDFLAGS += -Wl,-lgcc
LDFLAGS += -Wl,-lrdimon

################################################################################
# Create list of files for compilation                                         #
################################################################################

SRC_C = $(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.c))
SRC_S = $(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.s))

################################################################################
# Create list of object files and their dependencies                           #
################################################################################

OBJ_C = $(SRC_C:%.c=$(OBJ_DIR)/%.o)
OBJ_S = $(SRC_S:%.s=$(OBJ_DIR)/%.o)
OBJ = $(OBJ_C) $(OBJ_S)
DEP = $(OBJ:%.o=%.d)

################################################################################
# Default target                                                               #
################################################################################

.PHONY: all
all: debug

################################################################################
# Debug target                                                                 #
################################################################################

.PHONY: debug
debug:
	$(Q)$(MAKE) clean-out
	$(Q)$(MAKE) obj-debug
	$(Q)$(MAKE) elf
	$(Q)$(MAKE) size
	$(Q)$(MAKE) bin

################################################################################
# Release target                                                               #
################################################################################

.PHONY: release
release:
	$(Q)$(MAKE) clean
	$(Q)$(MAKE) obj-release
	$(Q)$(MAKE) elf
	$(Q)$(MAKE) size
	$(Q)$(MAKE) bin
	$(Q)$(MAKE) clean-obj

################################################################################
# Clean target                                                                 #
################################################################################

.PHONY: clean
clean:
	$(Q)$(MAKE) clean-obj
	$(Q)$(MAKE) clean-out

.PHONY: clean-obj
clean-obj:
	$(Q)$(ECHO) "Removing object directory..."
	$(Q)rm -rf $(OBJ_DIR)

.PHONY: clean-out
clean-out:
	$(Q)$(ECHO) "Removing output directory..."
	$(Q)rm -rf $(OUT_DIR)

################################################################################
# Flash firmware using DFU bootloader                                          #
################################################################################

.PHONY: dfu
dfu: $(BIN)
	$(Q)$(ECHO) "Flashing $(BIN)..."
	$(Q)$(DFU_UTIL) -d 0483:df11 -a 0 -s 0x08000000:leave -D $(BIN)

################################################################################
# Debug firmware using Ozone debugger (from Segger)                            #
################################################################################

.PHONY: ozone
ozone: debug
	$(Q)$(ECHO) "Launching Ozone debugger..."
	$(Q)$(OZONE) tools/ozone/ozone.jdebug

################################################################################
# Link object files                                                            #
################################################################################

.PHONY: elf
elf: $(ELF)

$(ELF): $(OBJ)
	$(Q)$(ECHO) "Linking object files..."
	$(Q)mkdir -p $(OUT_DIR)
	$(Q)$(CC) $(LDFLAGS) $(OBJ) -o $(ELF)
	$(Q)chmod -x $(MAP) $(ELF)

################################################################################
# Print information about size of sections                                     #
################################################################################

.PHONY: size
size: $(ELF)
	$(Q)$(ECHO) "Size of sections:"
	$(Q)$(SIZE) $(ELF)

################################################################################
# Create binary file                                                           #
################################################################################

.PHONY: bin
bin: $(BIN)

$(BIN): $(ELF)
	$(Q)$(ECHO) "Creating $(BIN) from $(ELF)..."
	$(Q)$(OBJCOPY) -O binary $(ELF) $(BIN)
	$(Q)chmod -x $(BIN)

################################################################################
# Compile source files                                                         #
################################################################################

.PHONY: obj-debug
obj-debug: CFLAGS += $(CFLAGS_DEBUG)
obj-debug: ASFLAGS += $(ASFLAGS_DEBUG)
obj-debug: $(OBJ)

.PHONY: obj-release
obj-release: CFLAGS += $(CFLAGS_RELEASE)
obj-release: ASFLAGS += $(ASFLAGS_RELEASE)
obj-release: $(OBJ)

################################################################################
# Compile "c" files                                                            #
################################################################################

$(OBJ_DIR)/%.o: %.c
	$(Q)$(ECHO) "Compiling: $<"
	$(Q)mkdir -p $(@D)
	$(Q)$(CC) -MMD -c $(CFLAGS) $(foreach d,$(INC_DIR),-I$d) $< -o $@

################################################################################
# Compile "s" files                                                            #
################################################################################

$(OBJ_DIR)/%.o: %.s
	$(Q)$(ECHO) "Compiling: $<"
	$(Q)mkdir -p $(@D)
	$(Q)$(CC) -MMD -c $(ASFLAGS) $< -o $@

################################################################################
# Include dependencies                                                         #
################################################################################

-include $(DEP)

################################################################################
# End of file                                                                  #
################################################################################
