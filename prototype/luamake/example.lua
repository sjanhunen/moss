-- Fundamental moss concepts:
--  Artifact: a completed build output (definition vs product)
--  Build Pipeline: a series of build functions that transform definition into product
--  Tool: build function that translats source files or forms products
--  Spore: collection of artifact definitions and build functions

local debug = extend("flags", "DEBUG");
local fast = extend("flags", "MCU_FAST");
local slow = extend("flags", "MCU_SLOW");

local clang_debug_tools = function(bt) return bt end
local clang_release_tools = function(bt) return bt end
local clang_with_fpu = function(bt) return bt end

-- Debug build pipeline
local debug_build = build(
    clang_debug_tools,
    debug,
    slow)

-- Release build pipeline
local release_build = build(
    clang_release_tools,
    fast)

math_lib = build(staticlib) {
    name = "fastmath.lib";
    source = [[ math1.c math2.c ]];
};

main_image = build(executable) {
    name = "main.exe";
    -- main_image requires math_lib within its build
    libs = {math_lib};
};

build(directory) {
    name = "output";

    build(directory, debug_build) {
        name = "debug";

        math_lib;
        main_image;
    };

    build(directory, release_build) {
        name = "release";

        main_image;
        build(clang_with_fpu) { math_lib };
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
