-- Would a generate(pattern, fn) tool be helpful for generated source code?

function translate(src, dst, recipe)
	return function(bt)
		-- TODO: return the rule in addition to the recipe
		return recipe(bt);
	end
end

function compile(src, recipe)
	return function(bt)
		-- TODO: return the rule in addition to the recipe
		return recipe(bt);
	end
end

function form(recipe)
    return function(bt)
		-- TODO: return the rule in addition to the recipe
        return recipe(bt);
    end
end

xml2cpp_tool = "/opt/tool/xml2cpp";
clang_home = "/opt/bin/clang";

-- Expansion within recipe templates:
-- ${<variable>} - expands to value of named variable in current scope or in build table
-- $@, $<, $^, $(...) - passed through to gnumake
function expand(bt, recipe)
	-- TODO: implement
	return recipe
end

xml2cpp = translate(".xml", ".cpp", function(bt)
	return expand(bt, "${xml2cpp_tool} -o $@ $^")
end)

clangcc = compile(".cpp", function(bt)
    return expand(bt,
		"${clang_home}/clangcc   		\z
        $(addprefix -D,${defines})   	\z
        $(addprefix -D,${defines})   	\z
        -o $@ $^")
end)

clangld = form(function(bt)
	return expand(bt, "${clang_home}/clangld -o $@ $<")
end)

clangar = form(function(bt)
	return expand(bt, "${clang_home}/clangar -o $@ $<")
end)

print(xml2cpp())
print(clangcc())
print(clangld())
print(clangar())
