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

all: $(YEAST.SPORES)
clean: $(addsuffix _clean, $(YEAST.SPORES))

define MOLD_TARGET_RULES

.PHONY: $1
.PHONY: $1_clean

$1_spore = .$1$(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT).spore
$1_clean_files += $$($1_spore)

$1: $$($1_spore)

$$($1_spore):
	touch $$@

$1_clean:
	rm -f $$($1_clean_files)

endef

$(foreach t, $(YEAST.SPORES), $(eval $(call MOLD_TARGET_RULES,$t)))

$(MOLD_OBJ_DIR) $(MOLD_BIN_DIR):
	mkdir -p $@
