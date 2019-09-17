# Templates are used to create the rules and recipes required by
# artifacts and their associated prerequisites.
#
# A template is simply a definition of a rule together with recipe.
#
# Templates are used to create both final artifacts and intermediates.
# An artifact definition must include all templates required by the artifact.

# Define named arguments for readability within templates
TEMPLATE.objdir = $3.$2.dir
TEMPLATE.target = $3

define TEMPLATE
$(if $($1),,$(error No template definition for '$1'))
$(eval $(call $1,$(strip $1),$(strip $2),$3))
endef
