ARMGGC_ROOT := /opt/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-eabi
SYSROOT := ${ARMGGC_ROOT}/arm_none_eabi
ARM_FLAGS := -mcpu=cortex-m0plus
CC := /opt/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gcc --sysroot=${SYSROOT} ${ARM_FLAGS}

BUILD_DIR := build
FIRMWARE_ELF := ${BUILD_DIR}/main.elf

BOOTLOADER_START := 0x2000

.PHONY: build
build: clean ${FIRMWARE_ELF}

${FIRMWARE_ELF}: ${BUILD_DIR}/main.o
	${CC} ${BUILD_DIR}/main.o -o ${FIRMWARE_ELF}

${BUILD_DIR}/main.o: main.c setup
	${CC} -c main.c -o ${BUILD_DIR}/main.o

.PHONY: setup
setup:
	mkdir -p build

.PHONY: clean
clean:
	rm -r ${BUILD_DIR}

.PHONY: flash
flash: clean ${FIRMWARE_BIN}
	bossac -p /dev/ttyACM0 --arduino-erase # Resets arduino to bootloader mode
	sleep 3 # takes a while until it is in bootloader mode
	bossac -p /dev/ttyACM0 --erase --write --verify --reset -o ${BOOTLOADER_START} ${FIRMWARE_BIN}


