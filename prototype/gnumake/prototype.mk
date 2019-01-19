#
# Test example
#

M.spores = one two three base
M.archs = armv5 host armv4
M.tools = gcc clang
M.variants = debug release

one.depends = two armv4/three
one.artifacts = lib1

base.stuff1 = base_stuff_1
base.stuff2 = another_stuff_1
base.artifacts = lib2
armv5/base.stuff_armv5 = special
armv5/base.artifacts = lib5
armv4/base.stuff_armv4 = special
armv4/base.artifacts = lib4

armv5/base.stuff1 = base_stuff_1_armv5

two.depends = base
two.code = src/two.c
two.artifacts = exe map bin hex

package.depends = two
package.code = $(armv5/two.artifact.lib) $(two.headers)
package.artifacts = tarball

armv5/two.depends = armv4/base
armv5/two.c.defines = USE_FPU
armv5/two.code = $(two.code) src/arm/*

# TODO: consider how core concepts might map back into
# a pure gnumake-based implementation of moss
#
# - Each build is described within a single Makefile
# - Nested builds are created with recursive make (a very targeted recursion)
# - Namespace is maintained with 'structures' and sub-processes
# - Structures can be created with some of the prototype approaches here

# Compare to luamake example
# Makefile
TOOLS = clangexe clangcc clangc++

# Explicit approach
myzip.files = release/main.exe debug/main.exe help.doc release-notes.txt
myzip.name = release.zip
myzip.rules = zipfile

# Recursive builds to traverse
BUILDS = debug/Makefile release/Makefile

ARTIFACTS = myzip

############################
# debug/Makefile
############################

-include $(HOME)/lib/math.mk
-include $(HOME)/app/main.mk

GENES = debug_build

ARTIFACTS = math_lib main_image

############################
# release/Makefile
############################

-include $(HOME)/lib/math.mk
-include $(HOME)/app/main.mk

GENES = release_build

ARTIFACTS = math_lib main_image

math_lib.genes += clang.fpu
math_lib.genes += clang.o3

# Back to prototype

include spore.mk
include doc.mk