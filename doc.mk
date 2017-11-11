# Create asciidoc-based output for makefile documentation and debugging

# Create combined list of all <arch>/$1.% and $1.% spore variables without duplicates
define M.def.all_spore_vars
$(sort $(notdir $(filter $(foreach arch,$(M.archs),$(arch)/$1.%) $1.%,$(.VARIABLES))))
endef

define M.def.spore_doc_row
| $1 | $($1) $(foreach arch,$(M.archs),| $($(arch)/$(1)))

endef

define M.def.spore_doc

= Spore $1

.Variables
|===
| Variable | arch=<none> $(foreach arch, $(M.archs), | arch=$(arch))
$(foreach var, $(call M.def.all_spore_vars,$1), $(call M.def.spore_doc_row,$(var)))
|===

endef

define M.def.doc

= Documentation for makefile `$(firstword $(MAKEFILE_LIST))`

$(foreach s,$(M.spores),$(call M.def.spore_doc,$s))

endef

.PHONY: doc
doc:
	@echo
	$(info $(M.def.doc))
