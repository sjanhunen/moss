# Top-level Makefile include for yeast

ifneq ($(MOLD_ARCH),)
MOLD_ARCH_EXT = .$(MOLD_ARCH)
endif

ifneq ($(MOLD_TOOL),)
MOLD_TOOL_EXT = .$(MOLD_TOOL)
endif

ifneq ($(MOLD_OBJ_DIR),)
MOLD_OBJ_DIR := $(MOLD_OBJ_DIR)/
endif

ifneq ($(MOLD_BIN_DIR),)
MOLD_BIN_DIR := $(MOLD_BIN_DIR)/
endif

include mold-gcc.mk
include mold-base.mk
include mold-c.mk
include mold-ar.mk
