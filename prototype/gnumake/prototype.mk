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

bin: bin/host bin/target

# Easily clone tables with default artifact names
bin/host/name1.out = $(table)
bin/target/name1.out = $(table)
bin/target/name2.out = $(table)

bin/host: $(call ARTIFACT, bin/host/name1.out)

# TODO: why does build fail if both artifacts are on same line?
bin/target: $(call ARTIFACT, bin/target/name1.out)
bin/target: $(call ARTIFACT, bin/target/name2.out)

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
