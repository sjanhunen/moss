# Mold rules for converting C source files to object files

define MOLD_C_RULES

$(MOLD_OBJ_DIR)%.$(1)$(MOLD_OBJ_EXT): %.c | $(MOLD_OBJ_DIR)
	$(call MOLD_CC, $$<, $$@)

endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_C_RULES,$t)))
