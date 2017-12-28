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

define freertos.static_lib(freertos)
	@doc: FreeRTOS kernel library
	@headers: freertos/include
endef

define freertos.lint(freertos)
	# Identical settings would be available to this second artifact
	@flags: level=1 pedantic=1
endef

define test_freertos.executable(freertos)
	@doc: Unit tests for FreeRTOS kernel
	@source: freertos/test_main.c $($1.tests)
	@static_lib: freertos catch c
endef

# Perhaps we could generate configuration headers like this
define freertos.header(freertos)
	@name: config_freertos.h
endef

# Little stand-alone library

define util.static_lib
	@source: hello.c util.c stuff.c
	@headers: include
endef

define test_util.executable
	@source: test_util.c
	@static_lib: util
endef

# Main applicaion

define myapp.exe
	@source: main.c application.c
	@static_lib: util freertos c
	@map_file: yes
endef

define myapp.bin
	@executable: myapp
endef

# Configuration options for armv5

define config(armv5)
	@tools: clang zip lint
	@lang.c.define: CPU_LE
endef

define config(armv5/freertos)
	@port: arm-cm4-gcc
	@memory_model: 1
	@stack_protection: yes
endef

# Configuration options for mips

define config(mips)
	@tools: gcc zip lint
	@lang.c.define: CPU_LE
endef

define config(mips/freertos)
	@port: mips-gcc
	@memory_model: 1
	@stack_protection: yes
endef

# Nothing will actually be built unless we create targets e.g.
# all: armv5/main.bin mips/main.bin
