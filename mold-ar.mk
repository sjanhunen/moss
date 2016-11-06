# Mold rules for creating target archives

define MOLD_AR_RULES

$1_clean_files += $(MOLD_BIN_DIR)$$($1_archive)$(MOLD_AR_EXT)

$$($1_spore): $(MOLD_BIN_DIR)$$($1_archive)$(MOLD_AR_EXT)
$(MOLD_BIN_DIR)$$($1_archive)$(MOLD_AR_EXT): $$($1_object)

endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_AR_RULES,$t)))

$(MOLD_BIN_DIR)%$(MOLD_AR_EXT): | $(MOLD_BIN_DIR)
	$(call MOLD_AR, $<, $@)
