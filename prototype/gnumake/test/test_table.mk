# All tables can be dumped with this
define DUMP
$(foreach v,$(filter $1.%, $(.VARIABLES)),$(info $v=$(value $v)))
endef

# Create namespace prefix $. (simply an alias for $1)
. = $1.

# Option 1: Explicit
#
# Simply write out all key value pairs

myzip.files = release/main.exe debug/main.exe help.doc release-notes.txt
myzip.name = release.zip
myzip.rules = zipfile

# Using $1 for mutations is important if we ever want to
# add arguments or reference the base definition name

base_table.const = 42

define base_table
$.the_number = $($0.const)
endef

# Option 2: Implicit table with explicit list of mutations

define mutation1
	$.files += mfile1
endef

define mutation2
	$.output = myoutput
	$.target_in_rule = $$@
endef

# TODO: how can we insert base mutation here before all definitions?
define my_table
	$.extends = base_table
	$.files = myfile1 myfile2
	$.mutations = mutation1 mutation2
endef

$(eval $(call my_table,my_table))
$(foreach m,$(my_table.mutations),$(eval $(call $m,my_table)))
$(call DUMP, my_table)

# Option 3: Implicit table with explicit call to each mutation at any point
#
# The advantage of call is $0 always operates as expected in any mutation
# and arguments can be used when necessary.
# The trouble with call is the risk of space!

define my_table_2
	$(call base_table,$1)

	$1.files = myfile1 myfile2

	$(call mutation1,$1)
	$(call mutation2,$1)
endef


$(eval $(call my_table_2,my_table_2))
$(call DUMP, my_table_2)


# Option 3: Implicit with composition outside definition 
#
# define my_table
# ...
# endef
#
# define mutationN
# ...
# endef
#
# variant1 = my_table mutation1 mutation2
#
# variant2 = base_table my_table mutation3 mutation4
#
# Nothing is expanded or combined at this point. The table definitions are only
# concatenated at this point.
#
# Concatenation and evaluation could check for existence of everything.
#
# $(call EXPAND, variant1)
# $(call EXPAND, variant2)
#
# This could also happen automatically as part of BUILD.


# Option 4: Implicit with composition within definition
#
# This looks to be the most promising approach with the least boilerplate.
# Mutations and tables can easily be created and composed using gnumake define.

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
# - {name} or [name] for table members (table.name) 
# - $_ for table name
# - Replacing $ with $$
#
# However, this adds a layer of hidden complexity and will be difficult to get
# correct for all cases. The bracket member replacement does have some merit
# and is worth at least considering. It could streamline table and template
# definitions if successful.

# It is much better to live with the need to use $$ explicitly in cases where a
# reference to the table itself is made or an automatic variable must be
# expanded later. It is possible to use explicit variable definition to clarify
# the names of arguments to functions and clean up some of the escaping. For
# example:

template.target = $1
template.artifact = $2

define my_template
$(template.target): $($(template.artifact).obj)
	@echo Building $$@
	@touch $$@
endef

myexe.obj = myexe.o

$(info $(call my_template,target.exe,myexe))
