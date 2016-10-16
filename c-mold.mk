# Mold configuration

MOLD_BINDIR ?= bin

ifneq ($(MOLD_ARCH),)
MOLD_ARCH_EXT = .$(MOLD_ARCH)
endif

ifneq ($(MOLD_TOOL),)
MOLD_TOOL_EXT = .$(MOLD_TOOL)
endif

ifneq ($(MOLD_OBJDIR),)
MOLD_OBJDIR := $(MOLD_OBJDIR)/
endif

# Arguments to MOLD_AR
# $1 = input
# $2 = output
MOLD_AR = ar -r $2 $1

# Arguments to MOLD_CC
# $1 = input
# $2 = output
MOLD_CC = gcc -c -o $2 $1

MOLD_AREXT = $(MOLD_ARCH)$(MOLD_TOOL).ar

MOLD_OBJEXT = $(MOLD_ARCH)$(MOLD_TOOL).o

.PHONY: all

# Generate a list of object files for each target
define MOLD_C_RULES
$1_object = $$(addsuffix $(MOLD_OBJEXT), $$(basename $$($1_source)))

.PHONY: $1_clean_obj
$1_clean_obj:
	rm -f $$($1_object)

.PHONY: $1_clean
$1_clean: $1_clean_obj

endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_C_RULES,$t)))

# Mold for converting C source files to object files

$(MOLD_OBJDIR)%$(MOLD_OBJEXT): %.c
	$(call MOLD_CC, $<, $@)
