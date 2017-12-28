define M.def.expand_struct
	$(subst :,=?,$(subst @,$2.,$(call $1,$2)))
endef

PREFIX.fpu = bobby

define STRUCT/sloppy1
@one : hello sjdklsd source.c
@two : bye sdjklsd $($1.fpu)
	@three:another sfjdkl
	#$1.four:another sfjdkl
	@five: yo $(if $($1.fpu),YES,NO)
	@six: humbug
endef

define STRUCT/sloppy2
@one : hello sjdklsd source.c
@two : bye sdjklsd $($1.fpu)
	@three:another sfjdkl
	#@four:another sfjdkl
	@five: yo $(if $($1.fpu),YES,NO)
	@six: humbug
	@const.prefix: my_special

	@source.arm: arm/arm.c
	@source.x86: intel/intel.c
	@lang.c.define: $($0.const.memory_model.$($1.memory_model))
endef

$(info $(call M.def.expand_struct,STRUCT/sloppy1,PREFIX))
$(eval $(call M.def.expand_struct,STRUCT/sloppy1,PREFIX))
$(info $(call M.def.expand_struct,STRUCT/sloppy2,PREFIX))
$(eval $(call M.def.expand_struct,STRUCT/sloppy2,PREFIX))
