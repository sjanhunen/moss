load luamake.so

lua-loadfile = $(lua loadfile("$1")())

# Load lua code from external file
$(lua-pcall dofile,luamake.lua)

# Clean direct evaluation of Lua code
$(lua-pcall print,This is a print from Lua)

# Evaluate string as code
$(info Result is $(lua return (5 + 5) / 3))

# Call custom eval function to evaluate string as code
$(info Result is $(lua-pcall eval, (5+5) / 3))

# Call function through load
# (arguments are evaluated as part of code)
$(info $(lua return proc('hi', 'another hello')))

# Call function directly
# (every argument explicitly a string)
$(info $(lua-pcall proc,hi,another hello))

.PHONY: hello
hello:
