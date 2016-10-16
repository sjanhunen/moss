# Mold rules for creating target archives

define MOLD_AR_RULES
$(MOLD_BIN_DIR)$$($1_archive)$(MOLD_AR_EXT): $$($1_object)

$1: $(MOLD_BIN_DIR)$$($1_archive)$(MOLD_AR_EXT)

.PHONY: $1_clean_ar
$1_clean_ar:
	rm -f $(MOLD_BIN_DIR)$$($1_archive)$(MOLD_AR_EXT)

$1_clean: $1_clean_ar

endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_AR_RULES,$t)))

$(MOLD_BIN_DIR)%$(MOLD_AR_EXT): | $(MOLD_BIN_DIR)
	$(call MOLD_AR, $<, $@)
