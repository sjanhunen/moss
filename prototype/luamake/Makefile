ifdef WINDIR
# ASSUMES we have makenew and libgnumake-1.dll.a in this directory
cygwin_opts = -L. -lgnumake-1.dll
endif

luamake.so: luamake.c
	gcc -shared -o $@ $^ $(cygwin_opts) -llua
