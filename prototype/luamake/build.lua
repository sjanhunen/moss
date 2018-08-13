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
--  Pipelines may be applied to nested tables for complex or hierarchical
--  builds with multiple build artifacts:
--
--      pipeline1 {
--          key1 = value1;
--          key2 = value2;
--          pipeline2 {
--              key3 = value3;
--              key4 = value4;
--          }
--      }
--
--  Core principles:
--  * Each build artifact is defined by a build table (Lua table)
--  * A build function transforms and returns a cloned copy of the build table
--  * A build pipeline is created by composing a series of build functions
--  * A build pipeline is itself a build function
--
--  Pipelines are constructed out of a series of transformation primitives:
--  * addprefix(key, prefix) - to string
--  * addsuffix(key, suffix) - to string
--  * append(key, item) - item to one list (table)
--  * extend(table) - one build table extends or inherits from another table
--  * etc.
--
--  The objective is to compose everything using build pipelines and primitives.

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
