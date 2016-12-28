# Rules for compiling C language files
#
# Requres:
# TOOL.C.CMD - command-line invocation for C compiler
# TOOL.C.DEP - command-line invocation for C dependency generator
#
# Creates:
# YEAST.C.RULES - C language rules required for each spore

define YEAST.C.RULES

$(MOLD_OBJ_DIR)%.$(1)$(MOLD_OBJ_EXT): %.c | $(MOLD_OBJ_DIR)
	$(call MOLD_CC, $$<, $$@)

endef

$(foreach t, $(YEAST.SPORES), $(eval $(call YEAST.C.RULES,$t)))
