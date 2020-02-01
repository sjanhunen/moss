# All templates can be dumped with this
define DUMP
$(foreach v,$(filter $1.%, $(.VARIABLES)),$(info $v=$(value $v)))
endef

# Multi-line template definition with explicit call for each mutation
#
# The advantage of call is $0 always operates as expected in any mutation
# and arguments can be used when necessary.
# The trouble with call is the risk of space!

define my_template
	$(call base_template,$1)

	$1.files = myfile1 myfile2

	$(call mutation1,$1)
	$(call mutation2,$1)
endef


$(eval $(call my_template,my_template))
$(call DUMP, my_template)

# Implicit with composition within definition
#
# This looks to be the most promising approach with the least boilerplate.
# Mutations and templates can easily be created and composed using gnumake define.
# However, the inconsistent behavior of $0 is a problem

define build_executable
$.rule = $.exe: $$($.src); touch $$@;
endef

define with_keys
$.key1 = First Key
$.key2 = Second Key
endef

define with_debug
$(with_keys)
$.cflags += -g -Od
endef

define with_bin
$.binfile = $2
endef

define with_my_binfile
$(call with_bin,$1,$.file)
endef

# Composing several mutations is easy
define with_hello_options
$(build_executable)
$(with_debug)
$(with_my_binfile)
$(detect_aux)
endef

# It is possible to hide some of the trickier expansions
# behind functions
define flag_for_aux
$.cflags += $$(if $$(filter aux.%,$$($.src)),-DAUX=1)
endef

# Common definitions can be placed in the base definition
# and remain accessible through $0 so long as the base
# definition is expanded through call
hello.common_src = common1.c common2.c

# Defining an artifact is compact
define hello
$.src = main.c aux.c other.c
$.cflags += -DSPECIAL=1
$.files += $($0.common_src)
$(flag_for_aux)
$(with_hello_options)
endef

# Cloning and extending is easy
define goodbye
$(call hello, $1)
$(with_debug)
$(with_my_binfile)
$.src += goodbye.c
endef

$(eval $(call hello,hello))
$(eval $(call goodbye,goodbye))

$(call DUMP, hello)
$(call DUMP, goodbye)

# It may be possible to make use of custom expansions such as
# - {name} or [name] for template members (template.name) 
# - $_ for template name
# - Replacing $ with $$
#
# However, this adds a layer of hidden complexity and will be difficult to get
# correct for all cases. The bracket member replacement does have some merit
# and is worth at least considering. It could template definitions if successful.

# It is much better to live with the need to use $$ explicitly in cases where a
# reference to the template itself is made or an automatic variable must be
# expanded later. 

# Named template arguments
#
# It is possible to use explicit variable definition to clarify
# the names of arguments to functions and clean up some of the escaping.
# For example:

my_template.target = $1
my_template.artifact = $2

define my_template
$(my_template.target): $($(my_template.artifact).obj)
	@echo Building $$@
	@touch $$@
endef

myexe.obj = myexe.o

$(info $(call my_template,target.exe,myexe))

# Option 3: definition "decorator"
# Create wrapper for definitions that can be used to trace when debugging
# Can also enforce certain conventions through the decorator
# e.g.
# define $(call mutation, <name>)
# ...
# endef

test_template = $$(info $(lastword $(MAKEFILE_LIST)) test_template ($1))$(call _test_template,$1)
define _test_template
$1.a = 5
$1.b = 7
endef

define top_template
$(call test_template,test1)
$(call test_template,test2)
endef

$(eval $(call top_template))
