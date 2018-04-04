-- Lua fuctions to be used from luamake.mk

proc = function(msg1, msg2)
	local welcome = "Welcome from Lua: ";
	return welcome .. msg1 .. "," .. msg2;
end

eval = function(code)
    return load("return " .. code)()
end

function seed(s)
    return s
end

function platform(name, p)
    return p
end

function executable(t)
    return t
end

function library(t)
    return t
end

function variant(t)
    return t
end

function files(f)
    -- Split files into table here
    return f
end

function list(f)
    -- Split files into table here
    return f
end
