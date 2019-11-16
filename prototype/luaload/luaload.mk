-load luaload.so

ifdef WINDIR
# ASSUMES we have makenew and libgnumake-1.dll.a in this directory
platform_opts = -L. -lgnumake-1.dll
endif

ifeq ($(shell uname),Darwin)
platform_opts = -undefined dynamic_lookup -I/usr/local/Cellar/lua/5.3.5_1/include/lua
endif

ifeq ($(shell uname),Linux)
platform_opts = -fPIC -I/usr/include/lua5.3
endif

luaload.so: luaload.c
	gcc -Wall -shared -o $@ $^ $(platform_opts) -llua5.3