# Rules for creating static libraries
#
# Arguments to TOOL.STATIC_LIB.CMD
# $1 = input
# $2 = output
# TOOL.STATIC_LIB.CMD - command-line invocation of archiver
#
# TOOL.STATIC_LIB.SUFFIX - libraries have this suffix appended
# YEAST.STATIC_LIB.PATH - path for placing completed library products

define YEAST.STATIC_LIB.RULES

$1.static_lib.product = \
	$(YEAST.STATIC_LIB.PATH)$$(TOOL.STATIC_LIB.PREFIX)$$($1.name)$(TOOL.STATIC_LIB.SUFFIX)
$1.products += $$($1.static_lib.product)

$$($1.spore): $$($1.static_lib.product)

$$($1.static_lib.product): $$($1.object) | $(YEAST.STATIC_LIB.PATH)
	$(call TOOL.STATIC_LIB.CMD, $$<, $$@)

endef

ifdef TOOL.STATIC_LIB.CMD
$(foreach s, $(YEAST.SPORES), $(eval $(call YEAST.STATIC_LIB.RULES,$s)))
endif
