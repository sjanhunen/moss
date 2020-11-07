include build.mk

define c.template
bin/%.o: %.c | $(TEMPLATE.objdir)
	touch $$@
endef

define exe.template
$(TEMPLATE.target): $($1.obj) | $(TEMPLATE.objdir)
	touch $$@
endef

# Create some helpful mutations for defining artifacts

define host_executable
$1.c.flags += --host_flag
$1.templates += c.template exe.template
endef

define target_executable
$1.c.flags += --target_flag
$1.templates += c.template exe.template
endef

# We specify the artifact name as part of the definition. This is because there
# is no easy way to compose tables in-line with target definitions. By default,
# the artifact name could default to the table name. This makes specializing
# artifacts very compact and guarantees a unique table name per artifact.

define table
$1.obj = bin/table.o
endef

define my_mutation
$1.my_mutation = 1
endef

bin: bin/host bin/target

define host_output
$(table)
$(host_executable)
endef

define target_output1
$(table)
$(my_mutation)

$1.name = bin/target/name1.out
$(target_executable)
endef

define target_output2
$(table)

$1.name = bin/target/name2.out
$(target_executable)
endef

# Easily clone tables with default artifact names
bin/host/name1.out = $(host_output)

bin/host: $(call BUILD, bin/host/name1.out)

# TODO: extend BUILD to accepts pattern like target_% or bin/xyz/%
bin/target: $(call BUILD, target_output1) $(call BUILD, target_output2)

define special1
$(table)
$1.name = special1.out
$(host_executable)
endef

define special2.out
$(table)
$(host_executable)
endef

# Using BUILD directly requires target syntax
$(call BUILD, special1):
$(call BUILD, special2.out):
