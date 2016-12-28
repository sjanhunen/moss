# Mold rules for creating target archives

define MOLD_AR_RULES

$1_clean_files += $(YEAST.EXECUTABLE.PATH)$$($1_archive)$(MOLD_AR_EXT)

$$($1_spore): $(YEAST.EXECUTABLE.PATH)$$($1_archive)$(MOLD_AR_EXT)
$(YEAST.EXECUTABLE.PATH)$$($1_archive)$(MOLD_AR_EXT): $$($1_object)

endef

$(foreach t, $(YEAST.SPORES), $(eval $(call MOLD_AR_RULES,$t)))

$(YEAST.EXECUTABLE.PATH)%$(MOLD_AR_EXT): | $(YEAST.EXECUTABLE.PATH)
	$(call MOLD_AR, $<, $@)
