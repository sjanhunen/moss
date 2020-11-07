TOOL.STATIC_LIB.CMD = ar -r $2 $1
TOOL.STATIC_LIB.SUFFIX = .a
TOOL.STATIC_LIB.PREFIX = lib

TOOL.EXECUTABLE.CMD = gcc \
	-L $(MOSS.STATIC_LIB.PATH) 		\
	$(if $3,$(addprefix -l,$3))		\
	-o $2							\
	$1

TOOL.C.COMPILE = gcc -c $(TOOL.C.FLAGS) -o $2 -MD $1

TOOL.OBJECT.SUFFIX = .o
TOOL.DEPEND.SUFFIX = .d
