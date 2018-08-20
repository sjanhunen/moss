-load luamake.so

ifdef WINDIR
# ASSUMES we have makenew and libgnumake-1.dll.a in this directory
platform_opts = -L. -lgnumake-1.dll
endif

ifeq ($(shell uname),Darwin)
platform_opts = -undefined dynamic_lookup
endif

luamake.so: luamake.c
	gcc -Wall -shared -o $@ $^ $(platform_opts) -llua

.PHONY: test

$(lua require,luamake)

test:
	# Call module function directly
	$(info $(lua proc,hi,another hello))
	# Use eval to convert to string for display
	$(info result is $(lua eval,tostring(55)))
