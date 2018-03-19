load luamake.so

define bob

bob = function(a)
	return a;
end

proc = function(msg1, msg2)
	local welcome = "Hello from Lua: ";
	print(welcome .. msg1 .. msg2);
end

endef

$(info $(lua-dostring $(bob)))
$(info $(lua-dostring bob(5)))

$(info $(lua-pcall proc, hi, another hello))

.PHONY: hello
hello:
