MOLD_AR_EXT := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(MOLD_AR_EXT)
TOOL.OBJECT.SUFFIX := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(TOOL.OBJECT.SUFFIX)

.PHONY: all clean

all: $(YEAST.SPORES)
clean: $(addsuffix _clean, $(YEAST.SPORES))

define YEAST_SPORE_RULES

.PHONY: $1
.PHONY: $1_clean

$1_spore = .$1$(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT).spore
$1_clean_files += $$($1_spore)

$1_object = $$(addsuffix .$(1)$(TOOL.OBJECT.SUFFIX), $$(basename $$($1_source)))
$1_object := $$(addprefix $(YEAST.OBJECT.PATH), $$($1_object))
$1_clean_files += $$($1_object)

$1: $$($1_spore)

$$($1_spore):
	touch $$@

$1_clean:
	rm -f $$($1_clean_files)

endef

$(foreach t, $(YEAST.SPORES), $(eval $(call YEAST_SPORE_RULES,$t)))

$(YEAST.OBJECT.PATH) $(YEAST.EXECUTABLE.PATH):
	mkdir -p $@
