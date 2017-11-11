#
# Test example
#

M.spores = one two three base
M.archs = armv5 host armv4
M.tools = gcc clang
M.variants = debug release

one.depends = two armv4/three

base.stuff1 = base_stuff_1
base.stuff2 = another_stuff_1
armv5/base.stuff_armv5 = special
armv4/base.stuff_armv4 = special

armv5/base.stuff1 = base_stuff_1_armv5

two.depends = base
two.source = src/two.c

armv5/two.depends = armv4/base
armv5/two.c.defines = USE_FPU
armv5/two.source = $(two.source) src/arm/*

#
# spore.mk
#

.PHONY: $(M.spores)

define M.var.spore

M.spore.$1.basedep = $(filter-out $(addsuffix /%,$(M.archs)),$($1.depends))
M.spore.$1.archdep = $(filter $(addsuffix /%,$(M.archs)),$($1.depends))

endef

$(foreach s, $(M.spores), $(eval $(call M.var.spore,$s)))

# Create spore variable $1 for architecture $2
define M.var.spore.arch
$2/$1 ?= $($1)
endef

# Spore variables need to iterate over spore and arch
$(foreach arch, $(M.archs), \
	$(foreach spore, $(M.spores), \
		$(foreach var, $(filter $(spore).%,$(.VARIABLES)), \
			$(eval $(call M.var.spore.arch,$(var),$(arch))))))

define M.rule.spore.arch
$2/$1: $(addprefix $2/,$(M.spore.$1.basedep)) $(M.spore.$1.archdep)
	@echo "BUILD $1 for $2"
endef

$(foreach a, $(M.archs), $(foreach s, $(M.spores), $(eval $(call M.rule.spore.arch,$s,$a))))

# Language rules need to iterate over arch to generate implicit rules with arch part of name

# Tools are simply definitions of the commands used by product and language rules and can make use of variant directly

# Product rules need to iterate over spores, archs, and product types
# (we can filter based on archs and products actually required)


#
# help.mk
#

# Create combined list of all <arch>/$1.% and $1.% spore variables without duplicates
define M.def.all_spore_vars
$(sort $(notdir $(filter $(foreach arch,$(M.archs),$(arch)/$1.%) $1.%,$(.VARIABLES))))
endef


define M.def.spore_help_row
| $1 | $($1) $(foreach arch,$(M.archs),| $($(arch)/$(1)))

endef


define M.def.spore_help

= Spore $1

.Variables
|===
| Variable | arch=<none> $(foreach arch, $(M.archs), | arch=$(arch))
$(foreach var, $(call M.def.all_spore_vars,$1), $(call M.def.spore_help_row,$(var)))
|===

endef

define M.def.help

= Help for makefile `$(firstword $(MAKEFILE_LIST))`

$(foreach s,$(M.spores),$(call M.def.spore_help,$s))

endef

.PHONY: help

help:
	@echo
	$(info $(M.def.help))

