# Rules for creating executables
#
# Arguments to TOOL.EXECUTABLE.CMD
# $1 = input
# $2 = output
# TOOL.EXECUTABLE.CMD - command-line invocation of archiver
#
# TOOL.EXECUTABLE.PREFIX - libraries have this prefix prepended to name
# TOOL.EXECUTABLE.SUFFIX - libraries have this suffix appended to name
# MOSS.EXECUTABLE.PATH - path for placing completed library products

define MOSS.EXECUTABLE.RULES
ifneq ($(filter $($1.products),executable),)

$1.executable.product = \
	$(MOSS.EXECUTABLE.PATH)$(TOOL.EXECUTABLE.PREFIX)$$($1.name)$(TOOL.EXECUTABLE.SUFFIX)

$1.targets += $$($1.executable.product)

$$($1.spore): $$($1.executable.product)

$$($1.executable.product): $$($1.objs) | $(MOSS.EXECUTABLE.PATH)
	$(call TOOL.EXECUTABLE.CMD, $$<, $$@, $($1.libraries))

endif
endef

ifdef TOOL.EXECUTABLE.CMD
$(foreach s, $(MOSS.SPORES), $(eval $(call MOSS.EXECUTABLE.RULES,$s)))
endif


