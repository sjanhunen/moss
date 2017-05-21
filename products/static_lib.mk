# Rules for creating static libraries
#
# Arguments to TOOL.STATIC_LIB.CMD
# $1 = input
# $2 = output
# TOOL.STATIC_LIB.CMD - command-line invocation of archiver
#
# TOOL.STATIC_LIB.PREFIX - libraries have this prefix prepended to name
# TOOL.STATIC_LIB.SUFFIX - libraries have this suffix appended to name
# MOSS.STATIC_LIB.PATH - path for placing completed library products

define MOSS.STATIC_LIB.RULES
ifneq ($(filter $($1.products),static_lib),)

$1.static_lib.product = \
	$(MOSS.STATIC_LIB.PATH)$(TOOL.STATIC_LIB.PREFIX)$$($1.name)$(TOOL.STATIC_LIB.SUFFIX)

$1.targets += $$($1.static_lib.product)

$$($1.spore): $$($1.static_lib.product)

$$($1.static_lib.product): $$($1.objs) | $(MOSS.STATIC_LIB.PATH)
	$(call TOOL.STATIC_LIB.CMD, $$<, $$@)

endif
endef

ifdef TOOL.STATIC_LIB.CMD
$(foreach s, $(MOSS.SPORES), $(eval $(call MOSS.STATIC_LIB.RULES,$s)))
endif
