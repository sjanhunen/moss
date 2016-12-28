MOLD_AR_EXT := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(MOLD_AR_EXT)
MOLD_OBJ_EXT := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(MOLD_OBJ_EXT)

.PHONY: all clean

all: $(YEAST.SPORES)
clean: $(addsuffix _clean, $(YEAST.SPORES))

define YEAST_SPORE_RULES

.PHONY: $1
.PHONY: $1_clean

$1_spore = .$1$(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT).spore
$1_clean_files += $$($1_spore)

$1_object = $$(addsuffix .$(1)$(MOLD_OBJ_EXT), $$(basename $$($1_source)))
$1_object := $$(addprefix $(MOLD_OBJ_DIR), $$($1_object))
$1_clean_files += $$($1_object)

$1: $$($1_spore)

$$($1_spore):
	touch $$@

$1_clean:
	rm -f $$($1_clean_files)

endef

$(foreach t, $(YEAST.SPORES), $(eval $(call YEAST_SPORE_RULES,$t)))

$(MOLD_OBJ_DIR) $(MOLD_BIN_DIR):
	mkdir -p $@
