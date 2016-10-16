# Mold rules for converting C source files to object files

$(MOLD_OBJDIR)%$(MOLD_OBJEXT): %.c
	$(call MOLD_CC, $<, $@)
