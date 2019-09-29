include artifact.mk

define c.template
bin/%.o: %.c | $(TEMPLATE.objdir)
	touch $$@
endef

define exe.template
$(TEMPLATE.target): $($1.obj) | $(TEMPLATE.objdir)
	touch $$@
endef

# We specify the artifact name as part of the definition. This is because there
# is no easy way to compose tables in-line with target definitions. By default,
# the artifact name could default to the table name. This makes specializing
# artifacts very compact and guarantees a unique table name per artifact.

define table
$1.templates = c.template exe.template
$1.obj = bin/table.o
endef

define my_mutation
$1.my_mutation = 1
endef

bin: bin/host bin/target

define host_output
$(table)
endef

define target_output1
$(table)
$(my_mutation)
$1.name = bin/target/name1.out
endef

define target_output2
$(table)
$1.name = bin/target/name2.out
endef

# Easily clone tables with default artifact names
bin/host/name1.out = $(host_output)

bin/host: $(call ARTIFACT, bin/host/name1.out)

# TODO: why does build fail if both artifacts are on same line?
bin/target: $(call ARTIFACT, target_output1)
bin/target: $(call ARTIFACT, target_output2)

# TODO: consider extending ARTIFACT to accepts pattern like target_% or bin/xyz/%

define special1
$(table)
$1.name = special1.out
endef

define special2.out
$(table)
endef

# Using ARTIFACT directly requires target syntax
$(call ARTIFACT, special1):
$(call ARTIFACT, special2.out):
