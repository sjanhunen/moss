ifndef _artifact

# NOTE: it is paramount that rules are expanded last after all other artifact
# definitions.  We may choose to use decorated template definitions to create
# rules.  Rules may also share unique namespaces with other templates in a
# module.  For example, the <artifact>.<rule> namespace could contain settings
# for rules.

# TODO: add support for default name

define _artifact
$(eval $(call $1,$1))
$(foreach rule,$($1.rules),$(eval $(call $(rule),$1)))
$($1.name)
endef

artifact = $(strip $(call _artifact,$(strip $1)))

endif
