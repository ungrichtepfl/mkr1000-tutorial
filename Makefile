LINKER_SCRIPT := ./mkr1000.ld
ARMGGC_ROOT := /opt/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-eabi
SYSROOT := ${ARMGGC_ROOT}/arm_none_eabi
ARM_FLAGS := -mcpu=cortex-m0plus
SPECS_FILE := ./mkr1000.specs
LD_FLAGS := --specs=${SPECS_FILE} -T ${LINKER_SCRIPT} 
CC_BIN := ${ARMGGC_ROOT}/bin
CC := ${CC_BIN}/arm-none-eabi-gcc --sysroot=${SYSROOT} ${ARM_FLAGS}

# NOTE: Change when you switch compiler
SANITIZE_OUTPUT_CMD := 2>&1 >/dev/null | sed 's/$(subst /,\/,${CC_BIN})\///g' | sed 's/lib\/gcc\/arm-none-eabi\///g' | sed 's/15\.2\.1\///g' | sed 's/\.\.\///g'

BUILD_DIR := ./build
FIRMWARE_ELF := ${BUILD_DIR}/main.elf

BOOTLOADER_START := 0x2000

.PHONY: compiledb
compiledb: | ${BUILD_DIR}
	compiledb -o ${BUILD_DIR}/compile_commands.json make all

.PHONY: all
all: ${FIRMWARE_ELF}

${FIRMWARE_ELF}: ${BUILD_DIR}/main.o ${BUILD_DIR}/startup.o ${LINKER_SCRIPT} ${SPECS_FILE}
	${CC} ${LD_FLAGS} -o ${FIRMWARE_ELF} ${BUILD_DIR}/main.o ${SANITIZE_OUTPUT_CMD}

${BUILD_DIR}/main.o: main.c | ${BUILD_DIR}
	${CC} -c -o ${BUILD_DIR}/main.o main.c ${SANITIZE_OUTPUT_CMD}

# .S because of case-problems on windows
${BUILD_DIR}/startup.o: startup.S | ${BUILD_DIR}
	${CC} -c -o ${BUILD_DIR}/startup.o startup.S ${SANITIZE_OUTPUT_CMD}

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}

.PHONY: clean
clean:
	rm ${BUILD_DIR} -rf

.PHONY: flash
flash: clean ${FIRMWARE_BIN}
	bossac -p /dev/ttyACM0 --arduino-erase # Resets arduino to bootloader mode
	sleep 3 # takes a while until it is in bootloader mode
	bossac -p /dev/ttyACM0 --erase --write --verify --reset -o ${BOOTLOADER_START} ${FIRMWARE_BIN}

