load luamake.so

define bob

bob = function(a)
	return a;
end

proc = function()
	print "Hello from Lua!";
end

endef

$(lua-dostring $(bob))
$(lua-dostring bob(5))

$(info $(lua-pcall proc))

.PHONY: hello
hello:
