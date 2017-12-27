# Spore definition is through Moss structure

define SEED/example.exe
	@source: \
		file_1 \
		file_2 \
		file_3

	@lang.c.defines: 		$(if $($1.bob), BOB_OPTION)
endef

# Options are explicitly defined for seeds

define SEED/example.debug
	@help: "Enable debug mode"
	@lang.c.define: DEBUG
endef

define SEED/example.march
	@help: "Select processor architecture"
endef

define SEED/example.march.x86
	@lang.c.define: 	MARCH=intel
	@source: 				src/march/intel.c
endef

define SEED/example.march.armv5
	@lang.c.define: 	MARCH=armv5
	@source: 				src/march/armv5.c
endef

# Configuration is how seeds are specialized for architecture

define ARCH/example.armv5
	# Must include a comment or some content before empty options
	@bob: yes
	@option: arm-yes
	@debug: no
endef

define M.def.configs
$(suffix $(filter ARCH/$1%,$(.VARIABLES)))
endef

define M.def.options
$(suffix $(filter SEED/$1.%,$(.VARIABLES)))
endef

# TODO: consider using the robust_expand macro approach here
define M.def.expand_seed
	$(patsubst %:,$2.% ?=, $(call SEED/$1,$2.VAR))
endef

define M.def.expand_config
	$(patsubst %:,$2.% ?=, $(ARCH/$1))
endef

# Expansion could replace normal assignment with conditional assignment
$(eval $(call M.def.expand_seed,example,example))

$(eval $(call M.def.expand_config,example.armv5,armv5/example))
$(eval $(call M.def.expand_config,example,armv5/example))

$(info ARCH Configurations for example: $(call M.def.configs,example))
$(info Options for example: $(call M.def.options,example))

$(info bob=$(if $(armv5/example.bob),ON,OFF))

define M.def.robust_expand2
	$(subst :,=?,$(subst @,$2.,$(call $1,$2)))
endef

PREFIX.fpu = bobby

define STRUCT/sloppy1
@one : hello sjdklsd source.c
@two : bye sdjklsd $($1.fpu)
	@three:another sfjdkl
	#$1.four:another sfjdkl
	@five: yo $(if $($1.fpu),YES,NO)
	@six: humbug
endef

define STRUCT/sloppy2
@one : hello sjdklsd source.c
@two : bye sdjklsd $($1.fpu)
	@three:another sfjdkl
	#@four:another sfjdkl
	@five: yo $(if $($1.fpu),YES,NO)
	@six: humbug
	@const.prefix: my_special

	@source.arm: arm/arm.c
	@source.x86: intel/intel.c
	@lang.c.define: $($0.const.memory_model.$($1.memory_model))
endef

$(info $(call M.def.robust_expand2,STRUCT/sloppy1,PREFIX))
$(eval $(call M.def.robust_expand2,STRUCT/sloppy1,PREFIX))
$(info $(call M.def.robust_expand2,STRUCT/sloppy2,PREFIX))
$(eval $(call M.def.robust_expand2,STRUCT/sloppy2,PREFIX))

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
