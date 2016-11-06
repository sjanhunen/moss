# Mold rules for converting C source files to object files

define MOLD_C_RULES

# TODO: need to append rather than set when we add CPP support
$1_object = $$(addsuffix .$(1)$(MOLD_OBJ_EXT), $$(basename $$($1_source)))
$1_object := $$(addprefix $(MOLD_OBJ_DIR), $$($1_object))
$1_clean_files += $$($1_object)

$(MOLD_OBJ_DIR)%.$(1)$(MOLD_OBJ_EXT): %.c | $(MOLD_OBJ_DIR)
	$(call MOLD_CC, $$<, $$@)

endef

$(foreach t, $(MOLD_TARGETS), $(eval $(call MOLD_C_RULES,$t)))
