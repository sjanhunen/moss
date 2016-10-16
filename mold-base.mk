ifneq ($(MOLD_ARCH),)
MOLD_ARCH_EXT = .$(MOLD_ARCH)
endif

ifneq ($(MOLD_TOOL),)
MOLD_TOOL_EXT = .$(MOLD_TOOL)
endif

ifneq ($(MOLD_OBJDIR),)
MOLD_OBJDIR := $(MOLD_OBJDIR)/
endif

MOLD_AREXT := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(MOLD_AREXT)
MOLD_OBJEXT := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(MOLD_OBJEXT)

.PHONY: all clean

all: $(MOLD_TARGETS)
clean: $(addsuffix _clean, $(MOLD_TARGETS))

define MOLD_TARGET_RULES

.PHONY: $1
.PHONY: $1_clean

$1_object = $$(addsuffix .$(1)$(MOLD_OBJEXT), $$(basename $$($1_source)))

.PHONY: $1_clean_obj
$1_clean_obj:
	rm -f $$($1_object)

.PHONY: $1_clean
$1_clean: $1_clean_obj

endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_TARGET_RULES,$t)))
