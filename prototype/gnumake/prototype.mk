include template.mk

define DUMP
$(foreach v,$(filter $1.%, $(.VARIABLES)),$(info $v=$($v)))
endef

# The trouble with evaluating the template before this point
# is that artifact-specific values are required.
define _ARTIFACT
$(eval $(call $1,$1))
$(eval $(foreach t,$($1.templates),$(call TEMPLATE,$t,$1)))
$(eval $1.dir: ; mkdir -p $$(dir $$@); touch $$@)
endef

# Expands all templates for artifact and returns artifact name
# We use strip here to cleanup extra white space.
define ARTIFACT
$(strip $(call _ARTIFACT,$(strip $1)))
$($(strip $1).name)
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

define c.template
bin/%.o: %.c | $(TEMPLATE.objdir)
	touch $$@
endef

define exe.template
$(TEMPLATE.target): $($2.obj) | $(TEMPLATE.objdir)
	touch $$@
endef

# We specify the artifact name as part of the definition. This is because there
# is no easy way to compose tables in-line with target definitions. By default,
# the artifact name could default to the table name. This makes specializing
# artifacts very compact and guarantees a unique table name per artifact.

define table
$1.templates = c.template exe.template
$1.obj = bin/$1.o
endef

bin: bin/host bin/target

define bin/host/name1.out 
$(table)
$1.name = $0
endef

bin/host: $(call ARTIFACT, bin/host/name1.out)

define bin/target/name1.out 
$(table)
$1.name = $0
endef

define bin/target/name2.out 
$(table)
$1.name = $0
endef

# TODO: why does build fail if both artifacts are on same line?
bin/target: $(call ARTIFACT, bin/target/name1.out)
bin/target: $(call ARTIFACT, bin/target/name2.out)

define name1.out
$(table)
$1.name = $0
endef

$(call DUMP,name1.out)

# Using ARTIFACT directly requires target syntax
$(call ARTIFACT, name1.out):
