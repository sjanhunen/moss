function translate(src, dst)
    if(dst == nil) then
        return function(recipe)
            print("translate " .. src .. " -> OBJ using recipe " .. recipe);
            return recipe;
        end
    else
        return function(recipe)
            print("translate " .. src .. " -> " .. dst .. " using recipe " .. recipe);
            return recipe;
        end
    end
end

function form(artifact)
    return function(recipe)
        print("form " .. artifact .. " using recipe " .. recipe);
        return recipe;
    end
end

xml2cpp_tool = "/opt/tool/xml2cpp";
clang_home = "/opt/bin/clang";

-- Expansion within recipe templates:
-- ${<variable>} - expands to value of named <variable>
-- $@, $<, $^ - passed through to gnumake

-- Translate from one source file to another source file
xml2cpp = translate(".xml", ".cpp") "${xml2cpp_tool} -o $@ $^";

-- Translate from source file to object file (i.e. compile)
clangcc = translate(".cpp")
    "${clang_home}/clangcc           \z
        $(addprefix -D,${defines})   \z
        $(addprefix -D,${defines})   \z
        -o $@ $^";

-- Would a generate(pattern, fn) tool be helpful for generated code?

clangld = form("executable") "${clang_home}/clangld -o $@ $<";

clangar = form("staticlib") "${clang_home}/clangar -o $@ $<";
