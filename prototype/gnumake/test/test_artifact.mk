include unittest.mk
include assert.mk
include artifact.mk

define test_rule
$($1.name):
	@echo "$($1.name)!"
endef

define test_artifact
$1.name = bob
$1.rules = test_rule
endef

.PHONY: target
target: $(call artifact, test_artifact)

ifdef $(call unittest,with_one_artifact)
$(call assert_equal,$(test_artifact.name),bob)
endif

ifdef $(call unittest,with_one_rule)
$(call assert_equal,$(shell make -f $(firstword $(MAKEFILE_LIST)) bob),bob!)
endif

ifdef $(call unittest,with_one_target)
$(call assert_equal,$(shell make -f $(firstword $(MAKEFILE_LIST)) target),bob!)
endif