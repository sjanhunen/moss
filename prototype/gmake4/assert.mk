ifndef _assert

_assert =

# Collection of helpful assert functions for gnumake

assert_equal = $(if $(filter $1,$2),\
			   ,					\
			   $(error `$(strip $1)` does not equal `$(strip $2)`))
endif
