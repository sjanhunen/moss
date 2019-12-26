ifneq ($(MODULE),)

# Use this as a module for testing import

$.variable1 = v1
$.variable2 = v2

define $.struct
$.member1 = 4
$.member2 = 8
endef

else

# Use this to define test cases

MODULE = $(strip $(firstword $(MAKEFILE_LIST)))

include unittest.mk
include import.mk

ifdef $(call unittest,with_module_prefix)

$(call import,$(MODULE),bob)
ifneq ($(bob.variable1),v1)
$(error FAIL)
endif

endif

ifdef $(call unittest,without_module_prefix)

$(call import,$(MODULE))
ifneq ($(variable1),v1)
$(error FAIL)
endif

endif

endif
