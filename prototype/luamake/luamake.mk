load luamake.so

# Load lua code from external file
$(lua require,luamake)
$(lua require,struct)

# Call built-in function directly
$(lua print,This is a print from Lua)

# Call custom eval function to evaluate string as code
$(info The result is $(lua eval, (5+5) / 3))

# Call module function directly
$(info $(lua proc,hi,another hello))

# Use eval to convert varible to string for display
$(info Files = $(lua eval,tostring(a)))

.PHONY: hello
hello:
