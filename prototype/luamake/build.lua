-- The build pipeline is fundamental to how moss creates build artifacts.
-- Pipelines are composed using the build function:
--
--      pipeline = build(f1, f2, ... fn)
--
-- This composes build functions f1 ... fn into a pipeline function that
-- transforms a build table. A new function is returned representing this
-- pipeline that takes a table as an argument and returns the transformed
-- table:
--
--      pipeline {
--          key1 = value1;
--          key2 = value2;
--      }
--
--  Pipelines may be nested within tables to create complex or hierarchical
--  builds with multiple build artifacts:
--
--      pipeline {
--          key1 = value1;
--          key2 = value2;
--          pipeline {
--              key3 = value3;
--              key4 = value4;
--          }
--      }
--
--  * Each build artifact is defined in a build table (which is a Lua table)
--  * A build function transforms a build table and returns a new (cloned) one
--  * A build pipeline is created by composing a series of build functions
--  * A build pipeline is itself a build function
--  * Build tables can be composed to produce nested artifacts (e.g directories)
--  * A series of primitive transformations on build tables will be defined:
--    * addprefix - to string
--    * addsuffix - to string
--    * append - item to one list (table)
--    * extend - one list (table) to another list (table)
--  * Objective: create everything out of build pipelines and primitives

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
        if type(v) == "table" then
            copy[k] = clone(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function build(...)
    local pipeline = {...}

    return function(bt)
        bt = clone(bt)
        -- TODO: Apply recursively for nested builds
        for i,step in ipairs(pipeline) do
            bt = step(bt);
        end
        return bt;
    end
end

function dumpbuild(bt, depth)
    if depth == nil then
        depth = 0
    end
    local prefix = "| "

    print(prefix:rep(depth) .. "+ " .. bt.name)

    depth = depth + 1
    for k, v in pairs(bt) do
        if type(k) == "string" then
            print(prefix:rep(depth) .. "- " .. k .. ": " .. tostring(v))
        end
    end
    for k, v in pairs(bt) do
        if type(k) == "number" then
            dumpbuild(v, depth)
        end
    end
end
