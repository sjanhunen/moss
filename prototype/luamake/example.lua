-- Fundamental concepts:
--  Operator: functions that operate on a single parameter
--  Gene: lowest level structural building block used to expand definitions
--  Product: a sequence of genes used to express an artifact
--  Artifact: a single fully express build product with name
--
-- Secondary concepts:
--  Tool:
--  Rule:
--  Trait:

require("operator")
require("artifact")

local rule = require("rule")
local exe = require("rules/exe")
local zipfile = require("tools/zipfile")
local clang = require("tools/clang")

local subdir = function(name)
    return operator { name = addprefix(name .. '/') }
end

-- A gene is the lowest level building block used to create software build products.
-- It is defined by a structure of operators that are used to expand product definition during
-- gene expression.
--
-- Example: definition single gene
-- 	g1 = gene { p1 = op1; p2 = op2 }
--
-- An operator transforms a single parameter.
--
-- Sequences of genes are composed to create products.
-- A gene remains focused on a single structure of operators.
--
-- Example: sequence of genes composed for product expression
--  p = product(g1, g2, g3)
--
-- This returns a function that may be evaluated as follows
--
-- p(<defn>) or p { <defn> } or p(g5, g6, g7) { <defn> }
--
-- The product definition is what the genes operate on to express the final product.
--
-- Artifacts are named outputs of fully expressed products within the build tree.
-- An artifact is a product with a name.
--
-- product(g1, g2, ... gN) {
-- 	artifact1 = g1;
--  artifact2 = gs;
--  ...
-- }

local gene = operator

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
