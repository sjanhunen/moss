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

# Prototype for new approach to SEED, OPTION, ARCH, CONFIG definition

define SEED(main.lib)
	@source: hello.c util.c stuff.c
endef

define SEED(main.exe)
	@source: main.c
	@lib: main c
endef

define SEED(main.bin)
	@source: main.exe
endef

# OPTION applies to all artifacts produced from main SEED
define OPTION(main.fpu)
	@source: fpu.c
	@lang.c.define: use_fpu
endef

define OPTION(main.fancy_logs)
	@source: fancy_logs.c
	@lang.c.include: fancy_include
endef

define ARCH(armv5)
	# TODO: what do we put here?
endef

define ARCH(x86)
	# TODO: what do we put here?
endef

define CONFIG(armv5/main)
	@fpu: yes
endef

define CONFIG(x86/main)
	@fancy_logs: yes
endef
