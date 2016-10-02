define MOLD_LIB_DEP =
$(MOLD_BINDIR)$$($1_archive)$(MOLD_AREXT): $$($1_object)
endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_LIB_DEP,$t))) 

$(MOLD_BINDIR)%$(MOLD_AREXT):
	$(call MOLD_AR, $<, $@)