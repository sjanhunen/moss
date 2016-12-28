# Rules for compiling C language files
#
# Arguments to TOOL.C.COMPILE
# $1 = input
# $2 = output
# TOOL.C.COMPILE - command-line invocation for C compiler
#
# TOOL.C.DEPEND - command-line invocation for C dependency generator
# TOOL.OBJECT.SUFFIX - object files have this suffix
# YEAST.OBJECT.PATH - object files are placed here
#
# Creates:
# YEAST.C.RULES - C language rules required for each spore

define YEAST.C.RULES

$(YEAST.OBJECT.PATH)%.$(1)$(TOOL.OBJECT.SUFFIX): %.c | $(YEAST.OBJECT.PATH)
	$(call TOOL.C.COMPILE, $$<, $$@)

endef

ifdef TOOL.C.COMPILE
$(foreach s, $(YEAST.SPORES), $(eval $(call YEAST.C.RULES,$s)))
endif
