-- Rules operate on artifacts to create makefile dependencies and recipes.
-- Four classes of rules are envisioned:
--  * Generate: function -> src
--	* Transpile: src -> src
--	* Compile: src -> obj
--	* Form: files -> artifact
--
-- Concepts (in JavaScript):
--  generate = rule("my_special_file", (defn) => "contents of file")
--  translate = rule("%.xml", "%.cpp", (defn) => `${defn.tool} ${defn.flags}`)
--  compile = rule("%.o", "%.cpp", (defn) => `${defn.tool} ${defn.flags}`)
--  form = rule((defn) => src2obj(defn.src), (defn) => `...`)

require("gene")

local rule = {}

-- Use private key to store rules in build table
local RULE_KEY = {}

-- TODO: create target dependencies with prerequisites
-- TODO: implement variable expansion within recipe templates:
-- ${<variable>} - expands to value of named variable in scope or build table
-- ${<fn>(arg1, ... argn)} - expands to return value of function fn in scope or build table
-- $@, $<, $^, $(...) - passed through to gnumake
local function expand(bt, recipe)
    if type(recipe) == "function" then
        return recipe(bt)
    else
        return recipe;
    end
end

function rule.translate(src, dst, recipe)
    return gene { [RULE_KEY] = append(function(bt)
		return expand(bt, recipe);
    end)}
end

function rule.compile(src, recipe)
    return gene { [RULE_KEY] = append(function(bt)
		return expand(bt, recipe);
    end)}
end

function rule.form(recipe)
    return gene { [RULE_KEY] = append(function(bt)
		return expand(bt, recipe);
    end)}
end

function rule.dump(bt)
    for k, v in pairs(bt) do
        if type(k) == "number" then
            rule.dump(v)
        end
    end
    if bt[RULE_KEY] then
        print("Rules for " .. bt.name)
        for k, v in pairs(bt[RULE_KEY]) do
            print(v(bt))
        end
    end
end

return rule
