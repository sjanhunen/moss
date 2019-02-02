-- Fundamental concepts:
--  Trait: fundamental building block of configuration and reuse
--  Artifact: an output product present in at least one build
--  Rule: patterns and recipes for transpiling, compiling, and forming artifacts
--  Build: named collections of artifacts, potentially containing other nested builds

require("gene")
require("artifact")

local rule = require("rule")
local exe = require("rules/exe")
local zipfile = require("tools/zipfile")
local clang = require("tools/clang")

local subdir = function(name)
    return gene { name = addprefix(name .. '/') }
end

local debug = gene { cflags = append "-DDEBUG" }
local fast = gene { cflags = append "-DLOG_NONE" }
local verbose = gene { cflags = append "-DLOG_VERBOSE" }

math_lib = artifact(clang.staticlib) {
    name = "fastmath.lib";
    source = {"math1.c", "math2.c"};
};

main_image = artifact(exe.rule) {
    name = "main.exe";
    source = "main.c";
    -- main_image requires math_lib within its build
    libs = "fastmath";
};

-- The spore global would be used to "export" artifacts
spore = {}

-- This is a placeholder for an actual trait that
-- configures build options
build_options = {}

-- TODO: refactor according to new build design thinking
spore.exports = build(subdir("output"), clangexe) {
    [build_options] = {
        debug = false;
        log = true;
        secure = false;
    };

    build(subdir("debug")) {
        [build_options] = { debug = true };

        math_lib;
        main_image;
    };

    build(subdir("release")) {
        [build_options] = { secure = true };

        main_image;
        build(clang.fpu)(math_lib);
    };

    -- In-place build artifact
    artifact(zipfile) {
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
rule.dump(spore.exports)
