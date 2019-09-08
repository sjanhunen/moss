# Templates are used to create the rules and recipes required for
# artifacts and their associated prerequisites.
#
# A template has the following table members:
# 	RECIPE - the command(s) used to create the artifact or intermediate
# 	PREREQ - any dependencies required by the final artifact
# 	TARGET - for intermediates, the implicit target pattern
# 	RULES - for artifacts that have prerequisites
#
# TODO: refactor to adopt this new approach to artifact templates
#
# $(call ARTIFACT, bin/host/myprogram.exe, myprogram)
# $(call ARTIFACT, bin/host/mylibrary.ar, mylib)

define _RULES
$(call $1.TARGET,$2): $(call $1.PREREQ,$2); $(call $1.RECIPE,$2)
endef

define _TEMPLATE
$(call $1.PREREQ,$1); $(call $1.RECIPE,$1)
$(foreach t,$($1.RULES),$(eval $(call _RULES,$t,$1)))
endef

TEMPLATE = $(call _TEMPLATE,$(strip $1))
