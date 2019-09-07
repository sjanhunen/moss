define $_EXPAND
	$(subst :,=?,$(subst @,$2.,$(call $1,$2)))
endef

$_PREFIX.fpu = bobby

define $_STRUCT/sloppy1
@one : hello sjdklsd source.c
@two : bye sdjklsd $($1.fpu)
	@three:another sfjdkl
	#$1.four:another sfjdkl
	@five: yo $(if $($1.fpu),YES,NO)
	@six: humbug
endef

define $_STRUCT/sloppy2
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

$(info $(call $_EXPAND,$_STRUCT/sloppy1,$_ONE))
$(eval $(call $_EXPAND,$_STRUCT/sloppy1,$_TWO))
$(info $(call $_EXPAND,$_STRUCT/sloppy2,$_THREE))
$(eval $(call $_EXPAND,$_STRUCT/sloppy2,$_FOUR))

$_HELLO=test
$_BYE=bye
