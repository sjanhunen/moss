ifndef _artifact

# NOTE: it is paramount that rules are expanded last after all other artifact
# definitions.  We may choose to use decorated template definitions to create
# rules.  Rules may also share unique namespaces with other templates in a
# module.  For example, the <artifact>.<rule> namespace could contain settings
# for rules.

# TODO: integrate object directory generation from build.mk
# TODO: integrate rule existence check from build.mk
# TODO: extend artifact to accept pattern like target_% or bin/xyz/%
# TODO: summarize design/implementation notest from build.mk
# TODO: delete build.mk and Makefile

define _artifact
$(eval $(call $1,$1))
$(eval $1.name ?= $1)
$(foreach rule,$($1.rules),$(eval $(call $(rule),$1)))
$($1.name)
endef

artifact = $(strip $(call _artifact,$(strip $1)))

endif
