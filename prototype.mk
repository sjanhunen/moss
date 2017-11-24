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

include spore.mk
include doc.mk
