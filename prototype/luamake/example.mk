.PHONY: hello
hello:

include luamake.mk

# Load lua modules
$(lua require,luamake)
$(lua require,build)
$(lua require,example)

# Call module function directly
$(info $(lua proc,hi,another hello))

# Use eval to convert to string for display
$(info result is $(lua eval,tostring(55)))
