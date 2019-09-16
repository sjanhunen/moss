include template.mk

define DUMP
$(foreach v,$(filter $1.%, $(.VARIABLES)),$(info $v=$($v)))
endef

# The trouble with evaluating the template before this point
# is that artifact-specific values are required.
define _ARTIFACT
$(eval $(call $2,$2))
$(eval $(foreach t,$($2.templates),$(call EVAL_TEMPLATE,$t,$2,$1)))
$(eval $1.$2.dir: ; mkdir -p $$(dir $$@); touch $$@)
endef

# Expands all templates for artifact and returns artifact name
# We use strip here to cleanup extra white space.
define ARTIFACT
$(strip $(call _ARTIFACT,$(strip $1),$(strip $2)))
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

define cobj
$1.PREREQ = %.c | $3.$2.dir
$1.TARGET = bin/%.o
$1.RECIPE = touch $$@
endef

define exe
$1.PREREQ = $$($2.obj) | $3.$2.dir
$1.TARGET = $3
$1.RECIPE = touch $$@
endef

define table
$1.templates = cobj exe
$1.obj = bin/$1.o
endef

bin: bin/host bin/target

bin/host: $(call ARTIFACT, bin/host/name1.out, table)

# TODO: why does build fail if both artifacts are on same line?
bin/target: $(call ARTIFACT, bin/target/name1.out, table)
bin/target: $(call ARTIFACT, bin/target/name2.out, table)

# Using ARTIFACT directly requires target syntax
$(call ARTIFACT, name1.out, table):
