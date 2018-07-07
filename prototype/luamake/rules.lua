-- Rules operate on build tables to create makefile rules + recipes for artifacts
-- Types of rules:
--  * Generate: TBD
--	* Translate: src -> src
--	* Compile: src -> obj
--	* Form: files + obj -> artifact

-- TBD: generate(src, recipe) tool be helpful for generated source code?

function translate(src, dst, recipe)
	return function(bt)
		-- TODO: return the rule in addition to the recipe
		-- TODO: Need to extend bt translate with recipe
		bt[translate] = recipe
		return bt;
	end
end

function compile(src, recipe)
	return function(bt)
		-- TODO: return the rule in addition to the recipe
		-- TODO: Need to extend bt compile form with recipe
		bt[compile] = recipe
		return bt;
	end
end

function form(recipe)
    return function(bt)
		-- TODO: return the rule in addition to the recipe
		-- TODO: Need to extend bt form with recipe
		bt[form] = recipe
		return bt;
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

print(xml2cpp({})[translate]())
print(clangcc({})[compile]())
print(clangld({})[form]())
print(clangar({})[form]())
