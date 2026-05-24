ARMGGC_ROOT := /opt/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-eabi
SYSROOT := ${ARMGGC_ROOT}/arm_none_eabi
ARM_FLAGS := -mcpu=cortex-m0plus
CC := /opt/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gcc --sysroot=${SYSROOT} ${ARM_FLAGS}

BUILD_DIR := build
FIRMWARE := ${BUILD_DIR}/main

.PHONY: all
all: clean ${FIRMWARE}

${FIRMWARE}: ${BUILD_DIR}/main.o
	${CC} ${BUILD_DIR}/main.o -o ${FIRMWARE}

${BUILD_DIR}/main.o: main.c setup
	${CC} -c main.c -o ${BUILD_DIR}/main.o

.PHONY: setup
setup:
	mkdir -p build

.PHONY: clean
clean:
	rm -r ${BUILD_DIR}

