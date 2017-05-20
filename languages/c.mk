# Rules for compiling C language files
#
# Arguments to TOOL.C.COMPILE
# $1 = input
# $2 = output
# TOOL.C.COMPILE - command-line invocation for C compiler
#
# TOOL.C.DEPEND - command-line invocation for C dependency generator
# TOOL.OBJECT.SUFFIX - object files have this suffix
# MOSS.OBJECT.PATH - object files are placed here
#
# Creates:
# MOSS.C.RULES - C language rules required for each spore

$(MOSS.OBJECT.PATH)%$(TOOL.OBJECT.SUFFIX): %.c
	$(call TOOL.C.COMPILE, $<, $@)
