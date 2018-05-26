-- Key moss concepts:
--  Trait: config -> build variables
--  Tool: build variables + traits -> build commands
--  Build: tool + traits -> artifact definition
--  Spore: a collection of trait, tool, and build definitions

math_lib = build(staticlib) {
    name = "fastmath.lib";
    source = [[ math1.c math2.c ]];
}

main_image = build(executable) {
    name = "main.exe";
    -- main_image requires math_lib within its build
    libs = {math_lib};
};

build(directory) {
    name = "output";

    [executable] = {
        form = clangld;
        translate = clangcc;
    };
    [staticlib] = {
        form = clangar;
        translate = clangcc;
    };

    [clangcc] = { cflags = "-Wall" };

    -- Traits cannot be expanded within a build unless they have been
    -- configured.  Traits are superior to global variables in that offer
    -- better scope control and are less brittle.  Specific traits can be
    -- overriden too: myconfig.trait = { }
    [myconfig] = {
        memory_model = "large";
        debug = false;
    };

    build(directory) {
        name = "debug";

        [clangcc] = { cflags = "-Og -DDEBUG" };

        -- Each artifact produced within a build node
        -- must be explicitly enumerated.
        math_lib, main_image
    };

    build(directory) {
        name = "release";

        [clangcc] = { cflags = "-O3" };
        [myconfig] = { debug = true };

        main_image,
        -- Explicit configuration for this build of math_lib
        math_lib {
            [clangcc] = { cflags = "-Mfpu" };
        };
    };

    -- In-place build artifact
    build(zipfile) {
        name = "release.zip";

        -- TODO: how do we select which main_image to use?
        files = {
            "release/main.exe",
            "debug/main.exe",
            "help.doc",
            "release-notes.txt"
        };
    };
};
