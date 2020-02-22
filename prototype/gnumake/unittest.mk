ifndef _unittest

_unittest.case = test_$(strip $1)
_unittest.file = $(strip $(firstword $(MAKEFILE_LIST)))
define _unittest

.PHONY: $(_unittest.case)

# Avoid recursion by only creating dependency in first invocation
ifndef TEST_CASE
unittest: $(_unittest.case)
endif

# Each test case is executed within a separate invocation of make
# TODO: implement support for expected return code (for failure testing)
$(_unittest.case):
	@echo $$@
	@make -s -f $(_unittest.file) $$@=y TEST_CASE=$$@
	@echo OK

endef

# Empty recipe for test
.PHONY: unittest
unittest:

# Decorated definition to create test case that can be used within an ifdef
unittest = test_$(strip $1) $(eval $(call _unittest,$1))

endif
