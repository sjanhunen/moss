include template.mk

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

# Use to dump any artifact table
define DUMP
$(foreach v,$(filter $1.%, $(.VARIABLES)),$(info $v=$($v)))
endef

# The trouble with evaluating the template before this point
# is that artifact-specific values are required.
define _ARTIFACT
$(eval $(call $1,$1))
$(eval $1.name ?= $1)
$(eval $1.dir = $(dir $($1.name)))
$(eval $(foreach t,$($1.templates),$(call TEMPLATE,$t,$1)))
$(if $(_has_obj_dir),$(eval $($1.name).dir: ; mkdir -p $$(dir $$@); touch $$@))
endef

# Expands table and templates for artifact and returns final artifact name.
# This must happen in a single line to support multiple ARTIFACTs
# as dependencies of a single target in one line.
define ARTIFACT
$(strip $(call _ARTIFACT,$(strip $1))) $($(strip $1).name)
endef