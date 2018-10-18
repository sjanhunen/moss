-- Fundamental moss concepts:
--  Artifact: the definition of a single completed build product
--  Operator: functions that operate on artifacts to transform definitions
--  Build: a composition of named artifacts that matches the names and scructure of output
--  Rule: operators that create makefile rules and recipes

require("operator")
require("artifact")

local rule = require("rule")
local exe = require("rules/exe")
local zipfile = require("tools/zipfile")
local clang = require("tools/clang")

local subdir = function(name)
    return operator { name = addprefix(name .. '/') }
end

-- An operator transforms a single parameter.
-- A spore is a composition of operators that transforms artifact parameters.
-- Spores are composed to create complete build artifacts.
--
-- artifact(s1, s2, ... sN) {
--  v1 = fn() or literal;
--  v2 = fn() or literal;
-- }
--
-- build(s1, s2, ... sN) {
-- ...
-- }

local spore = operator

local debug = spore { cflags = append "-DDEBUG" }
local fast = spore { cflags = append "-DLOG_NONE" }
local verbose = spore { cflags = append "-DLOG_VERBOSE" }

-- Debug build pipeline
local debug_build = build(clang.debug, debug, verbose)

-- Release build pipeline
local release_build = build(clang.release, fast)

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

-- TODO: refactor according to new build design thinking
spore.exports = build(subdir("output"), clangexe) {
    build(subdir("debug"), debug_build) {
        math_lib;
        main_image;
    };

    build(subdir("release"), release_build) {
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
