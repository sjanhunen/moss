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

# TODO: consider ARTIFACT that returns artifact name and expands rules
# myexe = $(call ARTIFACT, hello.exe, myexe)
# -OR-
# $(call ARTIFACT, hello.exe, myexe):

define BUILD
$(eval $(call $($(strip $2).rules),$(strip $2),$1))
endef

# Explicit approach to definition

myzip.files = release/main.exe debug/main.exe help.doc release-notes.txt
myzip.name = release.zip
myzip.rules = zipfile

# Compact definitions with DEFINE

define myexe
$1.rules = executable
$1.src = main.c
endef

$(call DEFINE, myexe)

define mylib
$1.src = lib1.c lib2.c
$1.rules = static_lib
endef

$(call DEFINE, mylib)

other_lib = $(mylib)

$(call DEFINE, other_lib)

other_lib.src := $(filter-out lib1.c, $(other_lib.src))


# Creation of rules using defintions

define executable
$2:
	@echo "Making EXE $$@ with $($1.src)"
endef

define static_lib
$2:
	@echo "Making LIB $$@ with $($1.src)"
endef

# Define and componse mutataions using MUTATE

$(call MUTATE, opt.debug, mylib)

define opt.files
$1.files += $2
endef

define opt.debug
$1.cflags += -d -Od
$1.src += debug.c
endef

define opt.clang
endef

define with_myoptions
$(call MUTATE, opt.files, $1, hello.txt goodbye.txt)
$(call MUTATE, opt.debug, $1)
$(call MUTATE, opt.clang, $1)
endef

# Create build artifacts by calling BUILD

$(info === myexe ===)
$(call DUMP, myexe)
$(info === mylib ===)
$(call DUMP, mylib)
$(info === other_lib ===)
$(call DUMP, other_lib)

$(call BUILD, hello.exe, myexe)
$(call BUILD, hello.lib, mylib)
