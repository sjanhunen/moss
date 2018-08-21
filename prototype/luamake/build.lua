-- The build pipeline is fundamental to how moss creates build artifacts.
-- Pipelines are composed using the build function:
--
--      pipeline = build(op1, op2, ... opn)
--
-- This composes build lambdas op1 ... opn into a build pipeline that
-- transforms a build table. A new function is returned representing this
-- pipeline that takes a table as an argument and returns the transformed
-- table:
--
--      -- Returns a new table that has passed through pipeline
--      pipeline {
--          key1 = value1;
--          key2 = value2;
--      }
--
--  A build lambda is created from a table of functions describing the
--  necessary transformations performed on a build table. Lambdas are
--  composed into build pipelines:
--
--      debug_flag = lambda { defines = append("DEBUG=1") }
--      debug_source = lambda { source = append("debug.c") }
--      debug_build = build(debug_flag, debug_source)
--
--  Or, using more compact notation:
--
--      debug_build = lambda {
--          defines = append("DEBUG=1");
--          source = append("debug.c");
--      }
--
--  Core principles:
--  * Every build artifact is defined within a unique build table (Lua table)
--  * Build tables may be nested for complex or hierarchical build trees
--  * A build operation transforms a particular variable within a build table
--  * A build operation is applied recursively to any nested build tables
--  * A build pipeline is a composition of a series of build operations
--  * A build pipeline is itself a build function
--
--  Lambdas are constructed using a series of transformation primitives that
--  operate on a single build variable:
--  * addprefix(prefix) - to string
--  * addsuffix(suffix) - to string
--  * append(item) - append item after end of list (table)
--  * prepend(item) - insert item at beginning of list (table)

require("lambda")

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

function build(...)
    local pipeline = {...}

    return function(bt)
        bt = deepcopy(bt)
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
