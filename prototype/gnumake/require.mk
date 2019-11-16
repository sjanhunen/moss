# REQURE solves the global namespace problem when including modules.
# Any module that follows the module scope convention can be included
# with all variable definitions prefixed in the specified namespace.
# REQUIRE guarantees that the module does not pollute the global namespace.
#
# Usage: $(call REQUIRE, module, prefix)

# TODO: implement nested require support
# - save and restore context variable _
# - only perform single before and after check

define _REQUIRE
$(eval _=$2.)
$(eval _BEFORE = $(.VARIABLES))
$(eval include $1)
$(eval _AFTER = $(.VARIABLES))
$(eval _DIFF = $(filter-out _BEFORE $_% $(_BEFORE),$(_AFTER)))
$(eval $(if $(_DIFF), $(error $1 defines non-module scope $(_DIFF)),))
$(eval undefine _BEFORE)
$(eval undefine _AFTER)
$(eval undefine _DIFF)
$(eval undefine _)
endef

define REQUIRE
$(eval $(call _REQUIRE,$(strip $1),$(strip $2)))
endef