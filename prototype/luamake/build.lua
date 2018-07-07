-- Builds:
--  * Each build artifact is defined in a build table (which is a Lua table)
--  * A build function transforms a build table and returns a new one
--  * A build pipeline is created by composing a series of build functions
--  * A build pipeline is iteself a build function
--  * Build artifacts are composable with nested artifacts (e.g directories)

function extend(variable, value)
    return function(bt)
        if bt[variable] == nil then
            bt[variable] = ""
        end
        bt[variable] = bt[variable] .. " " .. value;
        return bt;
    end
end

function prefix(value)
    return function(bt)
        bt.name = value ..bt.name;
        return bt
    end
end

function clone(bt)
    local copy = {}
    for k, v in pairs(bt) do
        copy[k] = v
    end
    return copy
end

function build(...)
    local pipeline = {...}
    return function(bt)
        bt = clone(bt)
        -- TODO: Run recursively on nested builds
        -- and perform a deep copy
        for i,step in ipairs(pipeline) do
            -- TODO: remove compatibility shim with example refactor
            if type(step) == "function" then
                bt = step(bt);
            end
        end
        return bt;
    end
end

function dumpbuild(bt)
    for k, v in pairs(bt) do
        if type(k) == "string" then
            print(k .. ":" .. v)
        elseif type(k) == "number" then
            dumpbuild(v)
        end
    end
end