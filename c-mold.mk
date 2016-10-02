# Mold configuration

MOLD_ARCH ?= host
MOLD_PLATFORM ?= debug

MOLD_OBJDIR ?= obj
MOLD_BINDIR ?= bin

ifneq ($(MOLD_ARCH),)
MOLD_OBJDIR := $(MOLD_OBJDIR)/$(MOLD_ARCH)
endif

ifneq ($(MOLD_PLATFORM),)
MOLD_OBJDIR := $(MOLD_OBJDIR)/$(MOLD_PLATFORM)
endif

ifneq ($(MOLD_OBJDIR),)
MOLD_OBJDIR := $(MOLD_OBJDIR)/
endif

# Mold configuration for gcc 

MOLD_OBJEXT = .o
MOLD_AREXT = .ar


# Arguments to MOLD_CC
# $1 = input
# $2 = output
MOLD_CC = gcc -c -o $2 $1

# Arguments to MOLD_AR
# $1 = input
# $2 = output
MOLD_AR = ar -r $2 $1

# Generate a list of object files for each target
define MOLD_OBJ_VAR = 
$1_object = $$(addsuffix $(MOLD_OBJEXT), $$(basename $$($1_source)))
endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_OBJ_VAR,$t))) 


# Mold for converting C source files to object files

$(MOLD_OBJDIR)%$(MOLD_OBJEXT): %.c
	$(call MOLD_CC, $<, $@)
