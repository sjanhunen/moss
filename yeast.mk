# Makefile for the yeast build system

# TODO: Confirm we are using a sufficient version of GNU make

#
# Determine where yeast is installed
#

YEAST.MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
YEAST.HOME := $(dir $(YEAST.MAKEFILE))

#
# Include toolchain definitions
#

define Yeast.tool.help

Toolchain Settings
==================

Toolchain and target architecture settings are configured using the following options.

	YEAST.TOOL=$(YEAST.TOOL)
	YEAST.ARCH=$(YEAST.ARCH)

endef

# TODO: ARCH should really be a tool-specific setting

ifdef YEAST.TOOL
include $(YEAST.HOME)/toolchains/$(YEAST.TOOL).mk
YEAST.ARCH_TOOL.NAME = $(addprefix $(addsuffix .,$(YEAST.ARCH)),$(YEAST.TOOL))
else
include $(YEAST.HOME)/toolchains/default.mk
YEAST.ARCH_TOOL.NAME = $(YEAST.ARCH)
endif

#
# Define build tree structure
#

define Yeast.path.help

Path Settings
=============

A number of configuration variables exist for customizing the build paths used
to store object and product files.

	## Location where yeast is installed
	YEAST.HOME=$(YEAST.HOME)

	## Root directory of generated build tree
	YEAST.BUILD.TREE=$(YEAST.BUILD.TREE)

	## Root directory of generated object files
	YEAST.OBJECT.PATH=$(YEAST.OBJECT.PATH)

	YEAST.EXECUTABLE.PATH=$(YEAST.EXECUTABLE.PATH)

	YEAST.STATIC_LIB.PATH=$(YEAST.STATIC_LIB.PATH)

endef

YEAST.BUILD.TREE ?= yeast.build

ifneq ($(strip $(YEAST.BUILD.TREE)),)
YEAST.OBJECT.PATH = $(YEAST.BUILD.TREE)/obj/$(YEAST.ARCH_TOOL.NAME)/
YEAST.EXECUTABLE.PATH = $(YEAST.BUILD.TREE)/bin/$(YEAST.ARCH_TOOL.NAME)/
YEAST.STATIC_LIB.PATH = $(YEAST.BUILD.TREE)/lib/$(YEAST.ARCH_TOOL.NAME)/
YEAST.SPORE.SUFFIX = $(addprefix .,$(YEAST.ARCH_TOOL.NAME)).spore
YEAST.SPORE.PATH = $(YEAST.BUILD.TREE)/
else
YEAST.SPORE.SUFFIX = .spore
endif

#
# Top-level phony targets
#

.PHONY: all clean

all: $(YEAST.SPORES)
clean: $(addsuffix _clean, $(YEAST.SPORES))

#
# Create spore definitions 
#

define YEAST_SPORE_RULES

.PHONY: $1
.PHONY: $1_clean

$1.name ?= $1
$1.spore = $(YEAST.SPORE.PATH).$$($1.name)$(YEAST.SPORE.SUFFIX)

$1.object = $$(addsuffix .$(1)$(TOOL.OBJECT.SUFFIX), $$(basename $$($1.source)))
$1.object := $$(addprefix $(YEAST.OBJECT.PATH), $$($1.object))

$1: $$($1.spore)

$$($1.spore):
	touch $$@

$1_clean:
	rm -f $$($1.products) $$($1.object) $$($1.spore)

endef

$(foreach t, $(YEAST.SPORES), $(eval $(call YEAST_SPORE_RULES,$t)))

#
# Create build tree structure
#

$(YEAST.OBJECT.PATH) $(YEAST.EXECUTABLE.PATH) $(YEAST.STATIC_LIB.PATH):
	mkdir -p $@

#
# Include source language-specific rules
#

include $(YEAST.HOME)/languages/*.mk

#
# Include build product-specific rules
#

include $(YEAST.HOME)/products/*.mk

#
# Targets for creating markdown and HTML help output
#

.PHONY: help Yeast.help

help: Yeast.help.html Yeast.help.markdown

Yeast.help:
	@echo $(info $(Yeast.tool.help))
	@echo $(info $(Yeast.path.help))

Yeast.help.markdown: $(MAKEFILE_LIST)
	make -f $(YEAST.MAKEFILE) Yeast.help > $@

Yeast.help.html: Yeast.help.markdown
	markdown $< > $@
