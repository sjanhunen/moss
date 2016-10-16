MOLD_OBJ_DIR = obj
MOLD_BIN_DIR = bin

MOLD_TARGETS += lite
lite_source = test.c
lite_archive = liblite

MOLD_TARGETS += heavy
heavy_source = test.c
heavy_archive = libheavy

include mold-gcc.mk
include mold-base.mk
include mold-c.mk
include mold-ar.mk
