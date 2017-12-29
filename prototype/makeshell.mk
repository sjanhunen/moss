# Performance test of nodejs as make shell

SHELL = $(TEST_SHELL)

ifeq ($(SHELL),node)

.SHELLFLAGS = -e
.ONESHELL:

define M.seq
	for(let i = 0; i < $1; ++i) {
		console.log(i);
	}
endef

define M.echo
	shell = require('shelljs');
	shell.echo('$1');
endef

endif

ifeq ($(SHELL),sh)

define M.seq
	seq $1
endef

define M.echo
	echo $1
endef

endif

ifeq ($(SHELL),python)

.SHELLFLAGS = -c
.ONESHELL:

define M.seq
	for i in range($1):
		print(i)
endef

define M.echo
	print($1)
endef

endif

var = $(shell $(call M.seq, 10))
list = $(foreach i, $(var), $(shell $(call M.echo,$i)))
$(info $(list))

.PHONY: test

test: