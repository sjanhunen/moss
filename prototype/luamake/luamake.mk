load luamake.so

lua-loadfile = $(lua loadfile("$1")())

# Load lua code
$(call lua-loadfile,luamake.lua)

# Clean direct evaluation of Lua code
$(lua print("Print from Lua!"))
$(info Result is $(lua return 5 + 5))

# Call function through load
# (arguments are evaluated as part of code)
$(info $(lua return proc('hi', 'another hello')))

# Call function directly
# (every argument explicitly a string)
$(info $(lua-pcall proc,hi,another hello))

.PHONY: hello
hello:
