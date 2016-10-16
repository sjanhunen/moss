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

MOLD_AR_EXT := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(MOLD_AR_EXT)
MOLD_OBJ_EXT := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(MOLD_OBJ_EXT)

.PHONY: all clean

all: $(MOLD_TARGETS)
clean: $(addsuffix _clean, $(MOLD_TARGETS))

define MOLD_TARGET_RULES

.PHONY: $1
.PHONY: $1_clean

$1_object = $$(addsuffix .$(1)$(MOLD_OBJ_EXT), $$(basename $$($1_source)))
$1_object := $$(addprefix $(MOLD_OBJ_DIR), $$($1_object))

.PHONY: $1_clean_obj
$1_clean_obj:
	rm -f $$($1_object)

.PHONY: $1_clean
$1_clean: $1_clean_obj

endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_TARGET_RULES,$t)))

$(MOLD_OBJ_DIR) $(MOLD_BIN_DIR):
	mkdir -p $@
