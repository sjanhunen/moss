# Spore definition is through Moss structure

define SPORE/example
	@name: 	example_name

	@source: \
		file_1 \
		file_2 \
		file_3

	@artifacts: 		lib exe

	# Think about this approach more to see if we can get away from
	# this style of expansion
	@my_example: 	$($1.bob)
	@c.defines: 		$(if $($1.bob), BOB_OPTION)
endef

# Options are explicitly defined for spores

define SPORE/example.debug
	@help: "Enable debug mode"
	@lang.c.define: DEBUG
endef

define SPORE/example.march
	@help: "Select processor architecture"
endef

define SPORE/example.march.x86
	@lang.c.define: 	MARCH=intel
	@source: 				src/march/intel.c
endef

define SPORE/example.march.armv5
	@lang.c.define: 	MARCH=armv5
	@source: 				src/march/armv5.c
endef

# Configuration is how spores are specialized for architecture

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
$(suffix $(filter SPORE/$1.%,$(.VARIABLES)))
endef

# TODO: consider using the robust_expand macro approach here
define M.def.expand_spore
	$(patsubst %:,$2.% ?=, $(call SPORE/$1,$2.VAR))
endef

define M.def.expand_config
	$(patsubst %:,$2.% ?=, $(ARCH/$1))
endef

# Expansion could replace normal assignment with conditional assignment
$(eval $(call M.def.expand_spore,example,example))

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
