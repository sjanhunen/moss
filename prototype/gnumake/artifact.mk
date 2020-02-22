ifndef _artifact

define _artifact
$(eval $(call $1,$1))
$(foreach rule,$($1.rules),$(eval $(call $(rule),$1)))
$($1.name)
endef

artifact = $(strip $(call _artifact,$(strip $1)))

endif