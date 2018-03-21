load luamake.so

# Load lua code from external file
$(lua dofile,luamake.lua)

# Clean direct evaluation of Lua code
$(lua print,This is a print from Lua)

# Call custom eval function to evaluate string as code
$(info The result is $(lua eval, (5+5) / 3))

# Call function directly
$(info $(lua proc,hi,another hello))

.PHONY: hello
hello:
