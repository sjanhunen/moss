# Rules for compiling C language files
#
# Requres:
# TOOL.C.COMPILE_CMD - command-line invocation for C compiler
# TOOL.C.DEPENDENCY_CMD - command-line invocation for C dependency generator
#
# Creates:
# YEAST.C.RULES - C language rules required for each spore

define YEAST.C.RULES

$(YEAST.OBJECT.PATH)%.$(1)$(MOLD_OBJ_EXT): %.c | $(YEAST.OBJECT.PATH)
	$(call MOLD_CC, $$<, $$@)

endef

$(foreach s, $(YEAST.SPORES), $(eval $(call YEAST.C.RULES,$s)))
