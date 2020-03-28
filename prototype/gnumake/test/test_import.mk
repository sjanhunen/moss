include unittest.mk
include assert.mk
include import.mk

ifdef $(call unittest,with_module_prefix)

$(call import,test/module.mk,bob)
$(call assert_equal, $(bob.variable1), v1)

$(eval $(call bob.struct,defn))
$(call assert_equal, $(defn.member1), 4)
$(call assert_equal, $(defn.member3), unique-for-import:bob.struct)

endif
ifdef $(call unittest,with_module_prefix_and_spaces)

$(call import, test/module.mk , sue )
$(call assert_equal, $(sue.variable1), v1)

$(eval $(call sue.struct,defn))
$(call assert_equal, $(defn.member1), 4)
$(call assert_equal, $(defn.member3), unique-for-import:sue.struct)

endif
ifdef $(call unittest,without_module_prefix)

$(call import,test/module.mk)
$(call assert_equal, $(variable1), v1)

$(eval $(call struct,defn))
$(call assert_equal, $(defn.member1), 4)
$(call assert_equal, $(defn.member3), unique-for-import:struct)

endif
ifdef $(call unittest,with_multiple_modules)

$(call import,test/module.mk,m1)
$(call import,test/module.mk,m2)
$(call import,test/module.mk)

$(eval $(call m1.struct,d1))
$(call assert_equal, $(d1.member3), unique-for-import:m1.struct)
$(call assert_equal, $(d1.m1.struct), unique-for-template:d1)

$(eval $(call m2.struct,d2))
$(call assert_equal, $(d2.member3), unique-for-import:m2.struct)
$(call assert_equal, $(d2.m2.struct), unique-for-template:d2)

$(eval $(call struct,d3))
$(call assert_equal, $(d3.member3), unique-for-import:struct)
$(call assert_equal, $(d3.struct), unique-for-template:d3)

endif
