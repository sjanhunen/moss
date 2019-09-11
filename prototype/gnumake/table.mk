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

# Option 2: Implicit with explicit mutation steps
#
# variant1 = my_table
#
# $(call TABLE, variant1, mutation1 mutation2)
#
# variant2 = my_table $(call TABLE, variant2, mutation1 mutation2)
#
# These approaches will always work regardless of the value of the mutations.
#
# There is value in making definition explicit with assignment either way.  The
# question is mainly over how tables are expanded and mutated.  Mutating in
# multiple steps is potentially risky as it may give the false impression that
# the table value can be used in the intermediate stages safely. It is more
# robust to define a table with all mutations at once.
#

# Option 3: Implicit with composition outside definition 
#
# Expand tables at the latest possible time. Keep them in variables for as long as possible.
#
# define my_table
# ...
# endef
#
# define mutationN
# ...
# endef
#
# variant1 = $(call COMPOSE, my_table mutation1 mutation2)
#
# variant2 = $(call COMPOSE, my_table mutation3 mutation4)
#
# Nothing is expanded at this point. The table definitions are only
# concatenated at this point.  COMPOSE needs to be very careful not to expand
# anything. Note that my_table is evaluated no differently than the mutations.
# The values of the variables are simply combined in order.
#
# Expansion and evaluation must be done later:
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

# Defining an artifact is compact
define hello
$1.src = main.c aux.c other.c
$1.cflags += -DSPECIAL=1
# Even conditionals aren't too bad
$1.cflags += $$(if $$(filter aux.%,$$($1.src)),-DAUX=1)
$1.files += $$($1.src)
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
