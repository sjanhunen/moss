ifneq ($(MODULE),)

# Use this as a module for testing REQUIRE

$.variable1 = v1
$.variable2 = v2

define $.struct
$.member1 = 4
$.member2 = 8
endef

else

# Use this to define test cases

MODULE = $(strip $(firstword $(MAKEFILE_LIST)))

include require.mk

# Combine name and list into one variable to support ifdef use
unittest = unittest_$(strip $1) $(eval TEST_CASES += $1)

ifdef $(call unittest,with_module_prefix)

$(call REQUIRE,$(MODULE),bob)
ifneq ($(bob.variable1),v1)
$(error FAIL)
endif

endif

ifdef $(call unittest,without_module_prefix)

$(call REQUIRE,$(MODULE))
ifneq ($(variable1),v1)
$(error FAIL)
endif

endif

ifneq ($(TEST_CASE),)

.PHONY: test
test:
	@echo OK

else

.PHONY: test $(TEST_CASES)
test: $(TEST_CASES)
$(TEST_CASES):
	@echo $@
	@make -s -f $(MODULE) unittest_$@=y TEST_CASE=unittest_$@

endif

endif
