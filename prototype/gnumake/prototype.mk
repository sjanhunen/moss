include template.mk

define DUMP
$(foreach v,$(filter $1.%, $(.VARIABLES)),$(info $v=$($v)))
endef

define _ARTIFACT
$(eval $1: $1.$2.preq; touch $1)
$(eval $1.$2.preq: $1.$2.dir; touch $$@)
$(eval $1.$2.dir: ; mkdir -p $$(dir $$@); touch $$@)
endef

# Expands all templates for artifact and returns artifact name
define ARTIFACT
$(call _ARTIFACT,$(strip $1),$(strip $2))
$(strip $1)
endef

# The challenge:
# 	We can only expand $@ within prerequisites or recipes (nowhere else!).
# 	And adding additional rules only possible for first variable expansion (not second).
#
# So, how do we generate rules for prerequisites for each target object directory?
# a) Invoking make recursively for each individual target (slow, tricky cross-build dependencies)
# b) Invoking make recursively for each nested build directory (boilerplate, tricky cross-build dependencies)
# c) Basing object directories off of table names rather than target names (possibly confusing)
# d) Accepting duplication or creation of ARTIFACTS without obvious rules (fastest, least duplication)
#
# Option d is looking like the clear winner.

# Totally non-recursive invocation of make with useful aggregate targets.
# Phony targets that do not match build structure can be easily created too.

bin: bin/host bin/target

bin/host: $(call ARTIFACT, bin/host/name1.out, table)

bin/target: \
	$(call ARTIFACT, bin/target/name1.out, table) \
	$(call ARTIFACT, bin/target/name2.out, table)

# Using ARTIFACT directly requires target syntax
$(call ARTIFACT, name1.out, table):
