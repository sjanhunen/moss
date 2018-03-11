# Performance tests for shell invocation from gnumake
# Requires gnumake 4.2.
#
# Set SHELL to one of:
#  - lua
#  - node
#  - python
#  - sh

SHELL = $(TEST_SHELL)

ifeq ($(SHELL),lua)

.SHELLFLAGS = -e
.ONESHELL:

define M.seq
for i = 1,$1 do
    print(i);
end
endef

define M.echo
print("$1");
endef

test:
	@
	print('Hello from lua');
	print('The target is $@');

endif

ifeq ($(SHELL),node)

.SHELLFLAGS = -e
.ONESHELL:

define M.seq
	for(let i = 0; i < $1; ++i) {
		console.log(i);
	}
endef

define M.echo
	console.log('$1');
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

var = $(shell $(call M.seq, 100))
list = $(foreach i, $(var), $(shell $(call M.echo,$i)))
$(info $(list))

.PHONY: test

test:
