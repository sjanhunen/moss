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
local zipfile = require("tools/zipfile")
local clang = require("tools/clang")

local subdir = function(name)
    return lambda { name = addprefix(name .. '/') }
end

local debug = lambda { cflags = append("-DDEBUG") }
local fast = lambda { cflags = append("-DLOG_NONE") }
local verbose = lambda { cflags = append("-DLOG_VERBOSE") }

-- Debug build pipeline
local debug_build = build(clang.debug, debug, verbose)

-- Release build pipeline
local release_build = build(clang.release, fast)

math_lib = build(clang.staticlib) {
    name = "fastmath.lib";
    source = {"math1.c", "math2.c"};
};

main_image = build(clang.executable) {
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
        build(clang.fpu)(math_lib);
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
