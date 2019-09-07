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

# Defining artifacts is through creation of a new target
# artifact: $(call TEMPLATE, defn)
#
# Where
# defn.templates - templates that are expanded to create all rules and recipes
# defn.depends - dependencies of final artifact
# defn.recipe - recipe for final artifact

TEMPLATE = $(eval $(call $(strip $1).template,$(strip $1))) $(call $(strip $1).depends,$(strip $1)); $(call $(strip $1).recipe,$(strip $1))

# Explicit approach to definition

myzip.files = release/main.exe debug/main.exe help.doc release-notes.txt
myzip.name = release.zip
myzip.rules = zipfile

# Compact definitions with DEFINE

define myexe
$1.src = main.c
endef

define myexe.recipe
touch $$@
endef

$(call DEFINE, myexe)

define mylib
$1.src = lib1.c lib2.c
endef

define mylib.recipe
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

hello.depends = hello.lib hello.obj.hello

# Recipes use a special stand-alone definition like below.
# Spacing and new-lines are not an issue given how TEMPLATE works!
define hello.recipe
@echo "Creating $$@ for $1"
touch $$@
endef

# TODO: find a way to define dependencies and recipes individually for templates
define hello.template
%.$1.cpp:
	touch $$@
%.obj.$1: %.$1.cpp
	touch $$@
endef

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
