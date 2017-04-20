# Rules for compiling C language files
#
# Arguments to TOOL.C.COMPILE
# $1 = input
# $2 = output
# TOOL.C.COMPILE - command-line invocation for C compiler
#
# TOOL.C.DEPEND - command-line invocation for C dependency generator
# TOOL.OBJECT.SUFFIX - object files have this suffix
# YEAST.OBJECT.PATH - object files are placed here
#
# Creates:
# YEAST.C.RULES - C language rules required for each spore

$(YEAST.OBJECT.PATH)%$(TOOL.OBJECT.SUFFIX): %.c
	$(call TOOL.C.COMPILE, $<, $@)


$(YEAST.OBJECT.PATH)%$(TOOL.DEPEND.SUFFIX): %.c
	$(call TOOL.C.DEPEND, $<, $@, $(@:.d=.o))
