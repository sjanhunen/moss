define MOLD_AR_RULES
$(MOLD_BINDIR)$$($1_archive)$(MOLD_AREXT): $$($1_object)

.PHONY: $1
$1: $(MOLD_BINDIR)$$($1_archive)$(MOLD_AREXT)

.PHONY: $1_clean_ar
$1_clean_ar:
	rm -f $(MOLD_BINDIR)$$($1_archive)$(MOLD_AREXT)

.PHONY: $1_clean
$1_clean: $1_clean_ar

endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_AR_RULES,$t)))

$(MOLD_BINDIR)%$(MOLD_AREXT):
	$(call MOLD_AR, $<, $@)
