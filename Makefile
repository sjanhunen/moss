YEAST.OBJECT.PATH = obj
YEAST.EXECUTABLE.PATH = bin
YEAST.STATIC_LIB.PATH = lib

YEAST.SPORES += lite
lite_source = test.c
lite_archive = liblite

YEAST.SPORES += heavy
heavy_source = test.c
heavy_archive = libheavy

include yeast.mk
