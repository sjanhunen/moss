# All tables can be dumped with this
define DUMP
$(foreach v,$(filter $1.%, $(.VARIABLES)),$(info $v=$(value $v)))
endef

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
$1.the_number = $($0.const)
endef

# Option 2: Implicit table with explicit list of mutations

define mutation1
	$1.files += mfile1
endef

define mutation2
	$1.output = myoutput
	$1.target_in_rule = $$@
endef

# TODO: how can we insert base mutation here before all definitions?
define my_table
	$1.extends = base_table
	$1.files = myfile1 myfile2
	$1.mutations = mutation1 mutation2
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
# This could also happen automatically as part of ARTIFACT.


# Option 4: Implicit with composition within definition
#
# This looks to be the most promising approach with the least boilerplate.
# Mutations and tables can easily be created and composed using gnumake define.

define build_executable
$1.rule = $1.exe: $$($1.src); touch $$@;
endef

define with_keys
$1.key1 = First Key
$1.key2 = Second Key
endef

define with_debug
$(with_keys)
$1.cflags += -g -Od
endef

define with_bin
$1.binfile = $2
endef

define with_my_binfile
$(call with_bin,$1,$1.file)
endef

# Composing several mutations is easy
define with_hello_options
$(build_executable)
$(with_debug)
$(with_my_binfile)
$(detect_aux)
endef

define filter_out_aux
$1.cflags += $$(if $$(filter aux.%,$$($1.src)),-DAUX=1)
endef

# Defining an artifact is compact
define hello
$1.src = main.c aux.c other.c
$1.cflags += -DSPECIAL=1
# Even conditionals aren't too bad
$1.files += $$($1.src)
$(call filter_out_aux,$1)
$(with_hello_options)
endef

# Cloning and extending is easy
define goodbye
$(hello)
$(with_debug)
$(with_my_binfile)
$1.src += goodbye.c
endef

$(eval $(call hello,hello))
$(eval $(call goodbye,goodbye))

$(call DUMP, hello)
$(call DUMP, goodbye)
