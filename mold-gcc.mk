# Arguments to MOLD_AR
# $1 = input
# $2 = output
MOLD_AR = ar -r $2 $1

# Arguments to MOLD_CC
# $1 = input
# $2 = output
MOLD_CC = gcc -c -o $2 $1

MOLD_AREXT = $(MOLD_ARCH)$(MOLD_TOOL).ar

MOLD_OBJEXT = $(MOLD_ARCH)$(MOLD_TOOL).o
