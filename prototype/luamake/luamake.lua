-- Lua fuctions to be used from luamake.mk

proc = function(msg1, msg2)
	local welcome = "Welcome from Lua: ";
	return welcome .. msg1 .. "," .. msg2;
end

eval = function(code)
    return load("return " .. code)()
end

function files(f)
    -- Split files into table here
    return f
end

function list(f)
    -- Split files into table here
    return f
end

function export(variables)
end
