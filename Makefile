YEAST.OBJECT.PATH = obj
YEAST.EXECUTABLE.PATH = bin
YEAST.STATIC_LIB.PATH = lib

YEAST.SPORES += lite
lite.source = test.c

YEAST.SPORES += heavy
heavy.source = test.c

include yeast.mk
