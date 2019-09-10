include template.mk

define DEFINE
$(eval $(call $1,$1))
endef

define DUMP
$(foreach v,$(filter $1.%, $(.VARIABLES)),$(info $v=$($v)))
endef

define MUTATE
$(eval $(call $(strip $1),$(strip $2),$(strip $3),$(strip $4),$(strip $5)))
endef

# TODO: should we create a CLONE? or perhaps combined DEFINE/MUTATE as TEMPLATE?
# $(call CLONE, myexe, testexe)
# $(call TEMPLATE, template, my_test_exe, for_clang_x86 for_bob others)

# TODO: consider creating MUTATION instead of MUTATE
# This would enable referencing mutations by name directly
# using_arm_cc = $(call MUTATION, using_arm_cc)
# ...
# $(call using_arm_cc, myexe)
# $(call with_debug, myexe)

# Explicit approach to definition

myzip.files = release/main.exe debug/main.exe help.doc release-notes.txt
myzip.name = release.zip
myzip.rules = zipfile

# Compact definitions with TABLEs
#
# Option 1
#
# variant1 = my_table
#
# $(call TABLE, variant1, mutation1 mutation2)
#
# variant2 = my_table $(call TABLE, variant2, mutation1 mutation2)
#
# These approaches will always work regardless of the value of the mutations.
#
# There is value in making definition explicit with assignment either way.  The
# question is mainly over how tables are expanded and mutated.  Mutating in
# multiple steps is potentially risky as it may give the false impression that
# the table value can be used in the intermediate stages safely. It is more
# robust to define a table with all mutations at once.
#
# Option 2
#
# Expand tables at the latest possible time. Keep them in variables for as long as possible.
#
# define my_table
# ...
# endef
#
# define mutationN
# ...
# endef
#
# variant1 = $(call COMPOSE, my_table mutation1 mutation2)
#
# variant2 = $(call COMPOSE, my_table mutation3 mutation4)
#
# Nothing is expanded at this point. The table definitions are only
# concatenated at this point.  COMPOSE needs to be very careful not to expand
# anything. Note that my_table is evaluated no differently than the mutations.
# The values of the variables are simply combined in order.
#
# Expansion and evaluation must be done later:
#
# $(call EXPAND, variant1)
# $(call EXPAND, variant2)
#
# This could also happen automatically as part of ARTIFACT.

define myexe
$1.src = main.c
endef

define myexe.RECIPE
touch $$@
endef

$(call DEFINE, myexe)

define mylib
$1.src = lib1.c lib2.c
endef

define mylib.RECIPE
touch $$@
endef

$(call DEFINE, mylib)

other_lib = $(mylib)

$(call DEFINE, other_lib)

other_lib.src := $(filter-out lib1.c, $(other_lib.src))

# Define and compose mutations using MUTATE

define opt.files
$1.files += $2
endef

define opt.debug
$1.cflags += -d -Od
$1.src += debug.c
endef

define opt.clang
endef

$(call MUTATE, opt.debug, mylib)

define with_myoptions
$(call MUTATE, opt.files, $1, hello.txt goodbye.txt)
$(call MUTATE, opt.debug, $1)
$(call MUTATE, opt.clang, $1)
endef

hello.PREREQ = hello.lib hello.obj.hello

# Recipes use a special stand-alone definition like below.
# Spacing and new-lines are not an issue given how TEMPLATE works!
define hello.RECIPE
@echo "Creating $$@ for $1"
touch $$@
endef

cpp.RECIPE = touch $$@
cpp.TARGET = %.obj.$1
cpp.PREREQ = %.cpp

cppgen.RECIPE = touch $$@
cppgen.TARGET = %.cpp

hello.RULES = cpp cppgen

.SECONDEXPANSION:

# Create build artifacts by calling TEMPLATE
# Definition of artifacts is very make-like and compact!

hello: $(call TEMPLATE, hello)
hello_again: $(call TEMPLATE, hello)
hello.lib: $(call TEMPLATE, mylib)
hello.exe: $(call TEMPLATE, myexe)

.PHONY: dump

dump:
	$(info === myexe ===)
	$(call DUMP, myexe)
	$(info === mylib ===)
	$(call DUMP, mylib)
	$(info === other_lib ===)
	$(call DUMP, other_lib)
	$(info === hello ===)
	$(call DUMP,hello)

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
