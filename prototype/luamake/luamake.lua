-- Lua fuctions to be used from luamake.mk

proc = function(msg1, msg2)
	local welcome = "Welcome from Lua: ";
	return welcome .. msg1 .. "," .. msg2;
end
