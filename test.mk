MOLD_OBJDIR=
MOLD_BINDIR=

MOLD_TARGETS += test

# A basic library used for testing
test_source = test.c
test_archive = libtest

include c-mold.mk
include ar-mold.mk
