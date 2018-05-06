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
        print("build sub-directory: " .. artifact);
    else
        print("build in place");
    end
    return function(e) return artifact end
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

-- The build tree is one of the most important concepts within moss.
-- Its function is to select and specialze genes for artifacts within the node.

build("output") {
    using(clangcc) { cflags = "-Wall" };
    using(clangld);

    using(myconfig) {
        memory_model = "large";
        debug = false;
    };

    build("debug") {
        main_image,
        -- math_lib will be created in this build as a dependency of main_image
        using(clangcc) { cflags = "-Og -DDEBUG" };
    };

    build("release") {
        main_image,
        using(clangcc) { cflags = "-O3" };
        using(myconfig) { debug = true };

        -- Explicit options for this build of math_lib
        build {
            math_lib,
            using(clangcc) { cflags = "-Mfpu" };
        };
    };

    -- In-place build and artifact definition
    build {
        artifact("zipfile") {
            name = "release.zip";
            -- TODO: fix ambiguous main image reference
            source = { main_image, "help.doc", "release-notes.txt" };
        },
        using(gzip) { flags = "--best" };
    };
};
