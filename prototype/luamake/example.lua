-- Fundamental moss concepts:
--  Artifact: a completed build output (definition vs product)
--  Build: a composition build functions that transform definition into product
--  Rule: series of functions that create makefile rules and recipes
--  Spore: collection of artifact definitions and build functions


--  Questions:
--  * is it worth distinguishing leaf artifacts from build nodes?
--  * can we combine lambda into build function?

require("lambda")
require("rules")

local clang_debug_tools = lambda { cflags = append("-g") }
local clang_release_tools = lambda { cflags = append("-O3") }
local clang_with_fpu = lambda { cflags = append("-ffpu") }

local debug = lambda { cflags = append("-DDEBUG") }
local fast = lambda { cflags = append("-DLOG_NONE") }
local verbose = lambda { cflags = append("-DLOG_VERBOSE") }

local subdir = function(name)
    return lambda { name = addprefix(name .. '/') }
end

-- Debug build pipeline
local debug_build = build(clang_debug_tools, debug, verbose)

-- Release build pipeline
local release_build = build(clang_release_tools, fast)

math_lib = build(staticlib) {
    name = "fastmath.lib";
    source = {"math1.c", "math2.c"};
};

main_image = build(executable) {
    name = "main.exe";
    source = "main.c";
    -- main_image requires math_lib within its build
    libs = "fastmath";
};

-- The spore global would be used to "export" artifacts
spore = {}

spore.exports = build(subdir("output")) {
    build(subdir("debug"), debug_build) {
        math_lib;
        main_image;
    };

    build(subdir("release"), release_build) {
        main_image;
        build(clang_with_fpu)(math_lib);
    };

    -- In-place build artifact
    build(zipfile) {
        name = "release.zip";

        files = {
            -- We can refer to artifacts directly by path
            "release/main.exe",
            "debug/main.exe",
            "help.doc",
            "release-notes.txt"
        };
    };
};

dumpbuild(spore.exports)
makerules(spore.exports)
