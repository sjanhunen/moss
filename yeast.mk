# Top-level Makefile include for yeast

ifneq ($(MOLD_ARCH),)
MOLD_ARCH_EXT = .$(MOLD_ARCH)
endif

ifneq ($(MOLD_TOOL),)
MOLD_TOOL_EXT = .$(MOLD_TOOL)
endif

ifneq ($(YEAST.OBJECT.PATH),)
YEAST.OBJECT.PATH := $(YEAST.OBJECT.PATH)/
endif

ifneq ($(YEAST.EXECUTABLE.PATH),)
YEAST.EXECUTABLE.PATH := $(YEAST.EXECUTABLE.PATH)/
endif

include mold-gcc.mk
include mold-base.mk
include mold-c.mk
include mold-ar.mk
