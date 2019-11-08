-- Key design points for builds:
--  Builds are trees containing named artifacts and nested builds.
--  Builds are the parents nodes in moss.
--	A build always has one or more children.
--	A build may contain nested builds.
--	A build is not an artifact.
--  Complex builds are composed hierarchically out of artifacts and other builds.
--  Mutations can be applied to all artifacts recursively when composing builds.
--	All output filenames are defined explicitly within build nodes.
--  The root is simply the topmost build containing all nested builds.
--  Nested builds are used to define build tree subdirectories.
--
-- Example:
--  build {
--   name1 = artifact { ... };
--   name2 = some_artifact;
--   ...
--   subdir = build { ... }
--  }
--
-- Mutations can be applied to builds in place
--
--  build(g1, g2, g3) { ... }
--
-- Names of artifacts and nested builds are given within the build definition itself.
-- This enables clear referencing of nodes through the root or through relative paths.
-- Another advantage is that specific artifacts or builds can be hand-picked from trees
-- and used stand alone.
--
-- Example 2:
--  build(g1, g2, .. gN) {
--   mylib = artifact(...) {};
--   main = mymodule.main_image;
--   test = mymodule.unit_tests;
--   docs = build(...) { };
--  }
--
-- References to artifacts within the build tree could be through special @artifact notation.
-- For example: ["release-" .. version] = zipfile { files = {"@myexe", "@mylib"} }
--
-- We may also consider builds as a sequence of ordered steps (without named artifacts):
--
-- build(...) {
--	step1, step2, step3
-- }
--
-- TBD: Are artifacts built before or after steps if they are combined?

require("mutation")

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
            if type(step) ~= "function" then
                step = mutation(step)
            end
            bt = step(bt);
        end
        return bt;
    end
end

function dumpbuild(bt, depth)
    if depth == nil then
        depth = 0
    end
    local prefix = " "

    depth = depth + 1
    for k, v in pairs(bt) do
        if type(k) == "string" then
            if type(v) == "table" then
                local txt = "" 
                for i,p in ipairs(v) do
                    if type(p) == "string" then
                        txt = txt .. "'" .. tostring(p) .. "',"
                    else
                        txt = txt .. tostring(p) .. ","
                    end
                end
                if txt:len() > 0 then
                    -- This is an ordered list value
                    print(prefix:rep(depth) .. "- " .. k .. ": {" .. txt .. "}")
                else
                    -- This is a nested table value
                    print(prefix:rep(depth) .. "+ " .. k .. ":")
                    dumpbuild(v, depth)
                end
            else
                -- This is a string value
                print(prefix:rep(depth) .. "- " .. k .. ": " .. tostring(v))
            end
        end
    end
end
