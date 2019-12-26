include unittest.mk
include assert.mk
include import.mk

ifdef $(call unittest,with_module_prefix)

$(call import,test/module.mk,bob)
$(call assert_equal, $(bob.variable1), v1)

endif
ifdef $(call unittest,without_module_prefix)

$(call import,test/module.mk)
$(call assert_equal, $(variable1), v1)

endif
