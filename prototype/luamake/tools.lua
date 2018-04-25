function translate(src, dst, name)
    return function(recipe) moss_translate(src, dst, "anonymous", recipe); end
end

function compile(src)
    return function(recipe) moss_compile(src, "anonymous", recipe); end
end

function form(artifact)
    return function(recipe) moss_form(artifact, "anonymous", recipe); end
end

xml2cpp = "/opt/tool/xml2cpp";
clang_home = "/opt/bin/clang";

config = seed {
    defines = "";
};

clang_config = seed {
    cc = {
    };
    ld = {
    }
};

-- Expansion within recipe templates:
-- @{.<name>} - expands to value of artifact parameter <name>
-- @{<seed>.<parameter>} - expands to value of seed parameter <seed>.<parameter> 
-- @{<variable>} - expands to value of named <variable>

xml2cpp = translate(".xml", ".cpp") "@{xml2cpp} -o $@ $^";

-- Consider this as translate(".cpp") - implicit output to object code
clangcc = compile(".cpp")
    "@{clang_home}/clangcc                  \z
        $(addprefix -D,@{config.defines})   \z
        $(addprefix -D,@{.defines})         \z
        -o $@ $^";

gzip = form("zip") "gzip -vf $@ $<";

clangld = form("executable") "@{clang_home}/clangld -o $@ $<";
