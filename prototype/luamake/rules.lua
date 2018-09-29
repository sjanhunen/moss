-- Rules operate on build tables to create makefile rules + recipes for artifacts:
--  * Generate: function -> src
--	* Translate: src -> src
--	* Compile: src -> obj
--	* Form: files + obj -> artifact

require("lambda")

-- Expansion within recipe templates:
-- ${<variable>} - expands to value of named variable in scope or build table
-- ${<fn>(arg1, ... argn)} - expands to return value of function fn in scope or build table
-- $@, $<, $^, $(...) - passed through to gnumake
function expand(bt, recipe)
	-- TODO: implement
	return recipe
end

function translate(src, dst, recipe)
    return lambda { rules = append(function(bt)
        -- TODO create both rule and recipe for makefile here
		return expand(bt, recipe);
    end)}
end

function compile(src, recipe)
    return lambda { rules = append(function(bt)
        -- TODO create both rule and recipe for makefile here
		return expand(bt, recipe);
    end)}
end

function form(recipe)
    return lambda { rules = append(function(bt)
        -- TODO create both rule and recipe for makefile here
		return expand(bt, recipe);
    end)}
end

local xml2cpp_tool = "/opt/tool/xml2cpp";
local clang_home = "/opt/bin/clang";

xml2cpp = translate(".xml", ".cpp", "${xml2cpp_tool} -o $@ $^")

clangcc = compile(".cpp",
		"${clang_home}/clangcc   		\z
        $(addprefix -D,${defines})   	\z
        $(addprefix -D,${defines})   	\z
        -o $@ $^")

executable = form("ld $@ $<")

zipfile = form("zip $@ $<")

staticlib = form("ar $@ $<")

function makerules(bt)
    for k, v in pairs(bt) do
        if type(k) == "number" then
            makerules(v)
        end
    end
    if bt.rules then
        print("Rules for " .. bt.name)
        for k, v in pairs(bt.rules) do
            print(v(bt))
        end
    end
end
