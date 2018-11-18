-- Fundamental concepts:
--  Pair: functions or definitions associated with a single parameter
--  Gene: lowest level structural building block used to expand definitions
--  Build: a collection of named build artifacts defined by gene sequences
--
-- Secondary concepts:
--  Tool:
--  Rule:
--  Trait:

require("gene")
require("artifact")

local rule = require("rule")
local exe = require("rules/exe")
local zipfile = require("tools/zipfile")
local clang = require("tools/clang")

local subdir = function(name)
    return gene { name = addprefix(name .. '/') }
end

-- Builds are collections of named artifacts of fully expressed gene sequences.
--
--  build {
--   artifact1 = g1;
--   artifact2 = g4;
--   ...
--   artifact3 = build { ... }
--  }
--
-- Builds may be nested to form subdirectories.
-- Builds may also be composed within the same directory level.
--
--  build {b1, b2, b3}
--
-- Gene sequences can be applied to builds in place
--
--  build(g1, g2, g3) { ... }

local debug = gene { cflags = append "-DDEBUG" }
local fast = gene { cflags = append "-DLOG_NONE" }
local verbose = gene { cflags = append "-DLOG_VERBOSE" }

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
