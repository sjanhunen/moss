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

$1.static_lib.product = $(YEAST.STATIC_LIB.PATH)$$($1_archive)$(TOOL.STATIC_LIB.SUFFIX)
$1_clean_files += $$($1.static_lib.product)

$$($1_spore): $$($1.static_lib.product)

$$($1.static_lib.product): $$($1_object) | $(YEAST.STATIC_LIB.PATH)
	$(call TOOL.STATIC_LIB.CMD, $$<, $$@)

endef

ifdef TOOL.STATIC_LIB.CMD
$(foreach s, $(YEAST.SPORES), $(eval $(call YEAST.STATIC_LIB.RULES,$s)))
endif
