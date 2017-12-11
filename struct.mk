# Spore definition is through Moss structure

define SPORE/example
	name: 	example_name

	source: \
		file_1 \
		file_2 \
		file_3

	artifacts: 		lib exe

	# Think about this approach more to see if we can get away from
	# this style of expansion
	my_example: 	$($1.bob)
	c.defines: 		$(if $($1.bob), BOB_OPTION)
endef

# Options are explicitly defined for spores

define SPORE/example.debug
	help: "Enable debug mode"
	values: y n
	default: y
endef

define SPORE/example.arch
	help: "Select processor architecture"
	values: armv5 mips x86
	default: mips
endef

# Configuration is how spores are specialized for architecture

define CONFIG/example
	# Must include a comment or some content before empty options
	bob:
	option: base-no
	debug: yes
endef

define CONFIG/example.armv5
	# Must include a comment or some content before empty options
	bob: yes
	option: arm-yes
	debug: no
endef

define M.def.configs
$(suffix $(filter CONFIG/$1%,$(.VARIABLES)))
endef

define M.def.options
$(suffix $(filter SPORE/$1.%,$(.VARIABLES)))
endef

define M.def.expand_spore
	$(patsubst %:,$2.% ?=, $(call SPORE/$1,$2.VAR))
endef

define M.def.expand_config
	$(patsubst %:,$2.% ?=, $(CONFIG/$1))
endef

# Expansion could replace normal assignment with conditional assignment
$(eval $(call M.def.expand_spore,example,example))

$(eval $(call M.def.expand_config,example.armv5,armv5/example))
$(eval $(call M.def.expand_config,example,armv5/example))

$(info ARCH Configurations for example: $(call M.def.configs,example))
$(info Options for example: $(call M.def.options,example))

$(info bob=$(if $(armv5/example.bob),ON,OFF))
