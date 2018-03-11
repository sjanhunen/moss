# Prototype for loadable module
# See: https://blog.melski.net/2013/11/29/whats-new-in-gnu-make-4-0/

define source
#include <stdlib.h>
#include <stdio.h>
#include <gnumake.h>

int plugin_is_GPL_compatible;

int fibonacci(int n)
{
    if (n < 2) {
        return n;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

char *gm_fibonacci(const char *nm, unsigned int argc, char **argv)
{
    char *buf  = gmk_alloc(33);
    snprintf(buf, 32, "%d", fibonacci(atoi(argv[0])));
    return buf;
}

int fibonacci_gmk_setup ()
{
    gmk_add_function ("fibonacci", gm_fibonacci, 1, 1, 0);
    return 1;
}
endef

fibonacci.so: fibonacci.c
	clang --shared -undefined dynamic_lookup -o $@ $^

fibonacci.c: $(lastword $(MAKEFILE_LIST))
	$(file >$@, $(source))

-load ./fibonacci.so

%:
	@echo $(fibonacci $@)
