-- Moss favors explicit definition over automatic discovery.
-- The build tree is a structure used to explicitly define how software is built.
-- This is in contrast to tools like autoconf that attempt to discover aspects of this.

-- Definition
function artifact(a)
    return function(v) return v end
end

-- Directive
function build(artifact)
    if(type(artifact) == "string") then
        print("build directory: " .. artifact);
    else
        print("build artifact: " .. artifact.name);
    end
    return function(e) return artifact end
end

-- Directive
function with(g)
    return function(c) return c end
end

-- Directive
function using(...)
    return function(c) return c end
end

math_lib = artifact("static_lib") {
    name = "fastmath.lib";
    source = [[ math1.c math2.c ]];
}

main_image = artifact("executable") {
    name = "main.exe";
    -- main_image requires math_lib within it's build
    libs = {math_lib};
};

-- The build directive is one of the most important concepts within moss
-- build(<artifact>) { }
-- A build directive may contain
--  - Nested 'build' directive (for directories only)
--  - 'with' directives for specializing genes
--  - 'using' directives for selecting tools
--  This encourages a natural language syntax like build(artifact) with(gene) using(tool)

-- Build structures used to explicitly define everything that is created
-- A directory artifact without name could imply current directory
build("output") {
    using(clangld, clangcc);

    with(myconfig) {
        memory_model = "large";
        debug = false;
    };

    build("debug") {
        -- math_lib will be created in this build as a dependency of main_image
        build(main_image);

        with(clang_config) {
            -- math_lib will inherit these cflags
            cc = { cflags = "-Og -DDEBUG" };
        };
    };
    build("release") {
        -- specify math_lib explicitly for this build
        build(math_lib) {
            -- special options for this build of math_lib
            with(clang_config) { flags = "-Mfpu" };
        };

        build(main_image);

        with(clang_config) {
            cc = { cflags = "-O3" };
        };
        with(myconfig) { debug = true };
    };

    build("package") {
        using(gzip);
        build(artifact("zipfile") {
            name = "release.zip";
            source = { main_image, "help.doc", "release-notes.txt" };
        });
    }
};
