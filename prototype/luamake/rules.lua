-- Rules operate on build tables to create makefile rules + recipes for artifacts:
--  * Generate: function -> src
--	* Translate: src -> src
--	* Compile: src -> obj
--	* Form: files + obj -> artifact

-- Consider separating this module as "rule"
-- rule defines translate, compile, form
--
-- Create "rules" modules under rules/
-- rules are generic rules for c, cpp, exe, slib, dlib, zip, etc.
--
-- c = require("rules/c")
-- Enables build tree entries for
-- [c.rule] - used for artifacts
-- [c.flags] - used by tools
-- [c.defines] - used by tools
-- [c.debug] - used by tools
-- [c.recipe] - defined by tools
--
-- Modules for tools are under tools/
-- tools implement definitions used by rules (clang, gcc, msvc, etc.)
--
-- clang = require("tools/clang")
-- Enables clang toolchain for rules in build
-- build(clang) { ... }

require("lambda")

local rules = {}

-- Use private key to store rules in build table
local RULE_KEY = {}

-- Expansion within recipe templates:
-- ${<variable>} - expands to value of named variable in scope or build table
-- ${<fn>(arg1, ... argn)} - expands to return value of function fn in scope or build table
-- $@, $<, $^, $(...) - passed through to gnumake
local function expand(bt, recipe)
	-- TODO: implement
	return recipe
end

function rules.translate(src, dst, recipe)
    return lambda { [RULE_KEY] = append(function(bt)
        -- TODO create both rule and recipe for makefile here
		return expand(bt, recipe);
    end)}
end

function rules.compile(src, recipe)
    return lambda { [RULE_KEY] = append(function(bt)
        -- TODO create both rule and recipe for makefile here
		return expand(bt, recipe);
    end)}
end

function rules.form(recipe)
    return lambda { [RULE_KEY] = append(function(bt)
        -- TODO create both rule and recipe for makefile here
		return expand(bt, recipe);
    end)}
end

function makerules(bt)
    for k, v in pairs(bt) do
        if type(k) == "number" then
            makerules(v)
        end
    end
    if bt[RULE_KEY] then
        print("Rules for " .. bt.name)
        for k, v in pairs(bt[RULE_KEY]) do
            print(v(bt))
        end
    end
end

return rules
