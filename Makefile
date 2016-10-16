MOLD_OBJDIR=
MOLD_BINDIR=

MOLD_TARGETS += lite heavy

lite_source = test.c
lite_archive = liblite

heavy_source = test.c
heavy_archive = libheavy

include mold-gcc.mk
include mold-base.mk
include mold-c.mk
include mold-ar.mk
