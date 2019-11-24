# REQURE solves the global namespace problem when including modules.
# Any module that follows the module scope convention can be included
# with all variable definitions prefixed in the specified namespace.
# REQUIRE guarantees that the module does not pollute the global namespace.
#
# Usage: $(call REQUIRE, module, prefix)

# TODO:
# - improve error handling in unit tests
# - add support for $/ relative paths
# - figure out how to restore $. after use
# - implement nested require support
#  - save and restore context variable _
#  - only perform single before and after check
#

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
# can't reference path $/ directly within variable definitions
# can reference $. or $/ within table definitions that are expanded via call

# TODO: why can't we undefine in here?
# We get missing separator errors

# Positional arguments for _REQUIRE
_REQUIRE.module = $1
_REQUIRE.name = $2

define _REQUIRE
. := $(if $(_REQUIRE.name),$(_REQUIRE.name).,)

_BEFORE := $$(.VARIABLES)
include $(_REQUIRE.module)
_AFTER := $$(.VARIABLES)

_DIFF := $$(if $(_REQUIRE.name),$$(filter-out _BEFORE $(_REQUIRE.name).% $$(_BEFORE),$$(_AFTER)),)
$$(if $$(_DIFF), $$(error $(_REQUIRE.module) defines non-module scope $$(_DIFF)),)
endef

REQUIRE = $(eval $(call _REQUIRE,$(strip $1),$(strip $2)))
