TOOL.STATIC_LIB.SUFFIX := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(TOOL.STATIC_LIB.SUFFIX)
TOOL.OBJECT.SUFFIX := $(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT)$(TOOL.OBJECT.SUFFIX)

.PHONY: all clean

all: $(YEAST.SPORES)
clean: $(addsuffix _clean, $(YEAST.SPORES))

define YEAST_SPORE_RULES

.PHONY: $1
.PHONY: $1_clean

$1.name ?= $1
$1.spore = .$$($1.name)$(MOLD_ARCH_EXT)$(MOLD_TOOL_EXT).spore

$1.object = $$(addsuffix .$(1)$(TOOL.OBJECT.SUFFIX), $$(basename $$($1.source)))
$1.object := $$(addprefix $(YEAST.OBJECT.PATH), $$($1.object))

# TODO: .spore files should probably also go into a "products" directory
$1: $$($1.spore)

$$($1.spore):
	touch $$@

$1_clean:
	rm -f $$($1.products) $$($1.object) $$($1.spore)

endef

$(foreach t, $(YEAST.SPORES), $(eval $(call YEAST_SPORE_RULES,$t)))

$(YEAST.OBJECT.PATH) $(YEAST.EXECUTABLE.PATH) $(YEAST.STATIC_LIB.PATH):
	mkdir -p $@
