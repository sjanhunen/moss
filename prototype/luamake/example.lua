-- Fundamental moss concepts:
--  Artifact: a completed build output (definition vs product)
--  Build: a composition build functions that transform definition into product
--  Rule: series of functions that create makefile rules and recipes
--  Spore: collection of artifact definitions and build functions


--  Questions:
--  * is it worth distinguishing leaf artifacts from build nodes?
--  * can we combine lambda into build function?

require("lambda")
local rule = require("rule")
local exe = require("rules/exe")
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


-- Refactor to core concepts of the build tree:
--
-- Artifacts are leaf nodes. An artifact is never a parent. An artifact is not a build.
-- Builds are parents nodes. A build always has one or more children. A build may contain nested builds. A build is not an artifact.
-- The Root build as the top level build containing all nested builds.
-- Operators are functions that operate recursively on all descendant artifacts within a node.
--
-- artifact(op1, op2, ... opn) { k1 = v1; k2 = v2; k3 = v3 }
--
-- build(op1, op2, ... opn) { n1 = artifact1, n2 = artifact2, n3 = artifact3, n4 = build(...) { ... } }
--
-- Names of artifacts and nested builds are given within the build definition itself.
-- This enables clear referencing of nodes through the root or through relative paths.
--
-- build(op1, op2, .. opN) {
--  name1 = artifact(...) {};
--  name2 = artifact(...) {};
--  name3 = build(...) { };
-- }
--
-- Builds may also be defined as a sequence of ordered steps (without named artifacts):
--
-- build(...) {
--	step1, step2, step3
-- }
--
-- Are artifacts build before or after steps if they are combined?


local artifact = build

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
