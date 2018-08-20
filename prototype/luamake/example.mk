.PHONY: all
all:

include luamake.mk

# Load lua modules
$(lua require,luamake)
$(lua require,build)
$(lua require,example)
