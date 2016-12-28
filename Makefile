MOLD_OBJ_DIR = obj
MOLD_BIN_DIR = bin

YEAST.SPORES += lite
lite_source = test.c
lite_archive = liblite

YEAST.SPORES += heavy
heavy_source = test.c
heavy_archive = libheavy

include yeast.mk
