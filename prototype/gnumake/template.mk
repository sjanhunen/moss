# Templates are used to create the rules and recipes required by
# artifacts and their associated prerequisites.
#
# A template has the following table members:
# 	RECIPE - the command(s) used to create the artifact or intermediate
# 	PREREQ - any dependencies required by the final artifact
# 	TARGET - for intermediates, the implicit target pattern
#
# Templates are used to create both final artifacts and intermediates.
# An artifact definition must include all templates required by the artifact.

define EVAL_TEMPLATE
$(if $($1),,$(error No template definition for '$1'))
$(eval $(call $1,$(strip $1),$(strip $2),$3))
$(eval $($1.TARGET): $($1.PREREQ); $(value $1.RECIPE))
endef
