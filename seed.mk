# Example of FreeRTOS library with several options

define seed(freertos)
	# Base variables for all configurations here
	@doc: FreeRTOS Real-Time Kernel
endef

define seed(freertos.port)
	@doc: Processor port for FreeROTS (as per port subdirectory name)
	@source: freertos/$1/port.c
	@tests: freertos/test/$1/test.c
endef

define seed(freertos.memory_model)
	@doc: Memory allocator for FreeRTOS runtime environment
endef

define seed(freertos.memory_model.static)
	@doc: Static without any malloc or free
	@source: freertos/static_mem.c
	@tests: freertos/test/test_static_mem.c
endef

define static_lib(freertos)
	@doc: FreeRTOS kernel library
	@seed: freertos
	@headers: freertos/include
endef

define lint(freertos)
	# Identical settings would be available to this second artifact
	@seed: freertos
	@flags: level=1 pedantic=1
endef

define executable(test_freertos)
	@doc: Unit tests for FreeRTOS kernel
	@seed: freertos
	@source: freertos/test_main.c $($1.tests)
	@static_lib: freertos catch c
endef

# Perhaps we could generate configuration headers like this
define header(freertos)
	@seed: freertos
	@name: config_freertos.h
endef

# Little stand-alone library

define static_lib(util)
	@source: hello.c util.c stuff.c
	@headers: include
endef

define executable(test_util)
	@source: test_util.c
	@static_lib: util
endef

# Main applicaion

define executable(myapp)
	@source: main.c application.c
	@static_lib: util freertos c
	@map_file: yes
endef

define binary(myapp)
	@executable: myapp
endef

# Architecture for armv5

define arch(armv5)
	@tools: clang zip lint
	@lang.c.define: CPU_LE
endef

define arch(armv5/freertos)
	@port: arm-cm4-gcc
	@memory_model: 1
	@stack_protection: yes
endef

# Architecture for mips

define arch(mips)
	@tools: gcc zip lint
	@lang.c.define: CPU_LE
endef

define arch(mips/freertos)
	@port: mips-gcc
	@memory_model: 1
	@stack_protection: yes
endef

# Nothing will actually be built unless we create targets e.g.
# all: armv5/main.bin mips/main.bin
