# Mold rules for converting C source files to object files

define MOLD_C_RULES

$(MOLD_OBJDIR)%.$(1)$(MOLD_OBJEXT): %.c
	$(call MOLD_CC, $$<, $$@)

endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_C_RULES,$t)))
