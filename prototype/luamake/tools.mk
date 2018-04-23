# Tool definition made directly from makefile

CLANG_HOME = /opt/bin/clang
XML2CPP = /opt/tools/xml2cpp
OBJEXT = .o

# Tools used to form artifacts from source and object files
$(lua moss_form, zip, gzip, gzip -vf $@ $<)

$(lua moss_form, executable, clangld, $(CLANG_HOME)/clangld -o $@ $<)

# Tools used to compile source code into object code
# TODO: need to sort out how we pass in cflags, etc.
$(lua moss_compile, .cpp, clangcc, $(CLANG_HOME)/clangcc -o $@ $^)

# Tools used to translate source code into source code
$(lua moss_translate, .xml, .cpp, xml2cpp, \
	$(XML2CPP) -D=mydef -o $@ $^ \
)
