# Arguments to MOLD_AR
# $1 = input
# $2 = output
MOLD_AR = ar -r $2 $1

TOOL.C.COMPILE = gcc -c -o $2 $1

MOLD_AR_EXT = .ar

TOOL.OBJECT.SUFFIX = .o
