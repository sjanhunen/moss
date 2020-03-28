ifndef _import

# Modular imports with namespace support for gnumake.
# Any module following the module scope convention may be imported
# with all variable definitions prefixed in the specified namespace.
#
# Usage: $(call import, module, namespace)
#
# If namespace is omitted, all module definitions are placed in the
# global namespace.

# TODO:
# - add support for $/ relative paths
# - implement nested import support
# - add import guard to avoid multiple imports into same namespace

# NOTES
#
# We can use an immediate assignemnt like this to capture module path
# for later use within a table definition
# $._path := ...
# It will be necessary to discover module name through $0 to actually
# reference $._path from within a table.
#
# CAVIETS
#
# can't capture module name or path unless we immediately expand
# must expand $. and $/ using call
# might be able to use $. and $/ within decorated template definitions

# TODO: why can't we undefine in here? We get missing separator errors.

# Positional arguments for _import
_import.module = $(strip $1)
_import.name = $(strip $2)

# Use $0 to figure out the context of . and expand appropriately
. = $(if $(filter import,$0),$(if $(_import.name),$(_import.name).,),$(if $1,$1.,$(error $$. is only valid in module or table context)))

define _import
_before := $$(.VARIABLES)
include $(_import.module)
_after := $$(.VARIABLES)

_diff := $$(if $(_import.name),$$(filter-out _before $(_import.name).% $$(_before),$$(_after)),)
$$(if $$(_diff), $$(error $(_import.module) defines non-module scope $$(_diff)),)
endef

import = $(eval $(call _import,$(strip $1),$(strip $2)))

endif
