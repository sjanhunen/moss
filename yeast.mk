# Makefile for the moss build system

# TODO: Confirm we are using a sufficient version of GNU make

#
# Determine where moss is installed
#

MOSS.MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
MOSS.HOME := $(dir $(MOSS.MAKEFILE))

#
# Include toolchain definitions
#

define Moss.tool.help

Toolchain Settings
==================

Toolchain and target architecture settings are configured using the following options.

	MOSS.TOOL=$(MOSS.TOOL)
	MOSS.ARCH=$(MOSS.ARCH)

endef

# TODO: ARCH should really be a tool-specific setting

ifdef MOSS.TOOL
include $(MOSS.HOME)/toolchains/$(MOSS.TOOL).mk
MOSS.ARCH_TOOL.NAME = $(addprefix $(addsuffix .,$(MOSS.ARCH)),$(MOSS.TOOL))
else
include $(MOSS.HOME)/toolchains/default.mk
MOSS.ARCH_TOOL.NAME = $(MOSS.ARCH)
endif

#
# Define build tree structure
#

define Moss.path.help

Path Settings
=============

A number of configuration variables exist for customizing the build paths used
to store object and product files.

	## Location where moss is installed
	MOSS.HOME=$(MOSS.HOME)

	## Root directory of generated build tree
	MOSS.BUILD.TREE=$(MOSS.BUILD.TREE)

	## Root directory of generated object files
	MOSS.OBJECT.PATH=$(MOSS.OBJECT.PATH)

	MOSS.EXECUTABLE.PATH=$(MOSS.EXECUTABLE.PATH)

	MOSS.STATIC_LIB.PATH=$(MOSS.STATIC_LIB.PATH)

endef

MOSS.BUILD.TREE ?= moss.build

ifneq ($(strip $(MOSS.BUILD.TREE)),)
MOSS.OBJECT.PATH = $(MOSS.BUILD.TREE)/obj/$(MOSS.ARCH_TOOL.NAME)/
MOSS.EXECUTABLE.PATH = $(MOSS.BUILD.TREE)/bin/$(MOSS.ARCH_TOOL.NAME)/
MOSS.STATIC_LIB.PATH = $(MOSS.BUILD.TREE)/lib/$(MOSS.ARCH_TOOL.NAME)/
MOSS.SPORE.SUFFIX = $(addprefix .,$(MOSS.ARCH_TOOL.NAME)).spore
MOSS.SPORE.PATH = $(MOSS.BUILD.TREE)/
else
MOSS.SPORE.SUFFIX = .spore
endif

#
# Top-level phony targets
#

.PHONY: all clean

all: $(MOSS.SPORES)
clean: $(addsuffix _clean, $(MOSS.SPORES))

#
# Create spore definitions
#

define MOSS_SPORE_RULES

.PHONY: $1
.PHONY: $1_clean

$1.name ?= $1
$1.spore = $(MOSS.SPORE.PATH).$$($1.name)$(MOSS.SPORE.SUFFIX)

$1.objs = $$(addsuffix $(TOOL.OBJECT.SUFFIX), $$(basename $$($1.source)))
$1.objs := $$(addprefix $(MOSS.OBJECT.PATH), $$($1.objs))

$1.deps = $$(addsuffix $(TOOL.DEPEND.SUFFIX), $$(basename $$($1.source)))
$1.deps := $$(addprefix $(MOSS.OBJECT.PATH), $$($1.deps))

$1.depend = $(MOSS.SPORE.PATH).$$($1.name).depend

.PRECIOUS: $$($1.objs)

$1.path.objs = $$(sort $$(dir $$($1.objs)))

$$($1.objs): | $$($1.path.objs)

MOSS.OBJECT.DIRS += $$($1.path.objs)

$1: $$($1.spore)

# Whenever an object file for this spore is rebuilt, the object file dependency
# outputs (deps) are combined into the overall dependency file

$$($1.spore): $$($1.objs)
	cat $$($1.deps) > $$($1.depend)
	touch $$@

$1_clean:
	rm -f $$($1.products) $$($1.objs) $$(1.deps) $$($1.depend) $$($1.spore)

# Include generated dependency information if it exists
-include $$($1.depend)

endef

$(foreach t, $(MOSS.SPORES), $(eval $(call MOSS_SPORE_RULES,$t)))


#
# Create build tree structure
#

$(MOSS.EXECUTABLE.PATH) $(MOSS.STATIC_LIB.PATH):
	mkdir -p $@


$(sort $(MOSS.OBJECT.PATH) $(MOSS.OBJECT.DIRS)):
	mkdir -p $@

#
# Include source language-specific rules
#

include $(MOSS.HOME)/languages/*.mk

#
# Include build product-specific rules
#

include $(MOSS.HOME)/products/*.mk

#
# Targets for creating markdown and HTML help output
#

# TODO: need to decide on best mechanism for NOOP (don't use echo below)

.PHONY: help Moss.help

help: Moss.help.html Moss.help.markdown

Moss.help:
	@echo $(info $(Moss.tool.help))
	@echo $(info $(Moss.path.help))

Moss.help.markdown: $(MAKEFILE_LIST)
	make -f $(MOSS.MAKEFILE) Moss.help > $@

Moss.help.html: Moss.help.markdown
	markdown $< > $@


#
# Targets for creating settings variable dumps
#

.PHONY: Moss.settings

define Moss.settings.dump
	$(info $1=$($1))

endef

Moss.settings.path = $(filter MOSS.%.PATH,$(.VARIABLES))

Moss.settings:
	@echo
	$(foreach v, $(Moss.settings.path), $(call Moss.settings.dump,$v))
