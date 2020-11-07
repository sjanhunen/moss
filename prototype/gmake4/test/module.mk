# This valid module is used for unit testing import

$.variable1 = v1
$.variable2 = v2

# Definitions like this are globally unique for a given instance of a module
# import and can be easily accessed from related definition using the $0
# variable.  This can be expanded with or without using call only within the
# scope of this module.
define $.struct.const
unique-for-import:$0
endef

# This definition must be expanded externally with call for the module
# references $0 to function as expected.
define $.struct

# Simple template scope assignment
$1.member1 = 4
$1.member2 = 8

# Use $0 to refer back to module scope definitions
$1.member3 = $($0.const)

# Use $0 to create a unique tempate scope member variable
$1.$0 = unique-for-template:$1

endef
