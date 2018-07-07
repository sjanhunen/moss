-- Builds:
--  * Each build artifact is fully defined through a build table
--  * All definitions (config, rules, variables) for the artifact are stored within the table
--  * Tables can be nested and composed for nested artifacts (e.g directories)
--  * The build function returns a build pipeline function that transforms a build table
--  * The output of a build pipeline is a build table
--  * Rules and variables are composed and modified through the pipeline
--  * Builds contain one or more local build variables
--  * Build variables can be defined directly
--  * Build variables can be composed from the pipeline
--  * Build variables can expanded within strings

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
