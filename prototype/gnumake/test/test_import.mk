include unittest.mk
include import.mk

ifdef $(call unittest,with_module_prefix)

$(call import,test/module.mk,bob)
ifneq ($(bob.variable1),v1)
$(error FAIL)
endif

endif

ifdef $(call unittest,without_module_prefix)

$(call import,test/module.mk)
ifneq ($(variable1),v1)
$(error FAIL)
endif

endif
