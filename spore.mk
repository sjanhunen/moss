# Create variables and rules for spores across all architectures

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

.PHONY: $(M.spores)

$(foreach a, $(M.archs), $(foreach s, $(M.spores), $(eval $(call M.rule.spore.arch,$s,$a))))

# Notes:
# Language rules need to iterate over arch to generate implicit rules with arch
# part of name.  Tools are simply definitions of the commands used by product
# and language rules and can make use of variant directly.  Product rules need
# to iterate over spores, archs, and product types (we can filter based on
# archs and products actually required).
