#
# Test example
#

M.spores = one two three base
M.archs = armv5 host armv4
M.tools = gcc clang
M.variants = debug release

one.depends = two armv4/three

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

# TODO: eliminate redundant variables here
define M.var.spore.arch

$2/$1.source ?= $($1.source)
$2/$1.depends ?= $($1.depends)
$2/$1.products ?= $($1.products)
endef

define M.rule.spore.arch
$2/$1: $(addprefix $2/,$(M.spore.$1.basedep)) $(M.spore.$1.archdep)
	@echo "BUILD $1 for $2"
endef

# Spore variables need to iterate over spore and arch
$(foreach a, $(M.archs), $(foreach s, $(M.spores), $(eval $(call M.var.spore.arch,$s,$a))))
$(foreach a, $(M.archs), $(foreach s, $(M.spores), $(eval $(call M.rule.spore.arch,$s,$a))))

# Language rules need to iterate over arch to generate implicit rules with arch part of name

# Tools are simply definitions of the commands used by product and language rules and can make use of variant directly

# Product rules need to iterate over spores, archs, and product types
# (we can filter based on archs and products actually required)


#
# help.mk
#


define M.adoc.spore

// Begin

= spore=$1, arch=$2

- depends = $($2/$1.depends)
- source = $($2/$1.source)


// End
endef

.PHONY: help

help:
	@echo
	$(info = Help for Moss)
	$(info $(foreach s,$(M.spores),$(foreach a,$(M.archs),$(call M.adoc.spore,$s,$a))))

