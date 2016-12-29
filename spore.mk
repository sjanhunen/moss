.PHONY: all clean

all: $(YEAST.SPORES)
clean: $(addsuffix _clean, $(YEAST.SPORES))

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

$(YEAST.OBJECT.PATH) $(YEAST.EXECUTABLE.PATH) $(YEAST.STATIC_LIB.PATH):
	mkdir -p $@
