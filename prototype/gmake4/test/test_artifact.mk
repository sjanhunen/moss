include unittest.mk
include assert.mk
include artifact.mk

define single_rule
.PHONY: $($1.name)
$($1.name):
	@echo "$($1.name)!"
endef

define chained_rule_1
.PHONY: $($1.name)
$($1.name): $($1.name).dep
endef

define chained_rule_2
.PHONY: $($1.name)
$($1.name).dep:
	@echo "$($1.name)!"
endef

# Artifacts can be defined explicitly without templates
explicit_artifact.name = sue
explicit_artifact.rules = single_rule

# Artifacts can also be defined using templates
define simple_artifact
$1.name = bob
$1.rules = single_rule
endef

define chained_artifact
$1.name = larry
$1.rules = chained_rule_1 chained_rule_2
endef

.PHONY: target
target: $(call artifact, simple_artifact)
$(call artifact, chained_artifact):
$(call artifact, explicit_artifact):

ifdef $(call unittest,with_explicit_definition)
$(call assert_equal,$(shell make -f $(firstword $(MAKEFILE_LIST)) sue),sue!)
endif

ifdef $(call unittest,with_one_artifact)
$(call assert_equal,$(simple_artifact.name),bob)
endif

ifdef $(call unittest,with_one_rule)
$(call assert_equal,$(shell make -f $(firstword $(MAKEFILE_LIST)) bob),bob!)
endif

ifdef $(call unittest,with_one_target)
$(call assert_equal,$(shell make -f $(firstword $(MAKEFILE_LIST)) target),bob!)
endif

ifdef $(call unittest,with_two_rules)
$(call assert_equal,$(shell make -f $(firstword $(MAKEFILE_LIST)) larry),larry!)
endif

