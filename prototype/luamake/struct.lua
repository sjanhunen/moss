-- Moss core concepts:
--  Artifact: a completed software build output (e.g. executable, library, etc.)
--  Build Tree: a hierarchical structure used to
--      * define and organize the artifacts that will be formed
--      * specify the tools used to form artifacts
--      * specialize the genes used within artifacts by build
--  Spore: a reusable template used to form a class of build artifact
--  Gene: a configurable unit of definition used for spore artifacts

myconfig = seed {
    -- A flag that is simply present or absent
    debug = flag {
        doc = "Set this to enable debug",
        -- These are only present if flag is true
        defines = "DEBUG=1",
        source = "src/debug/special.c"
    },
    memory_model = choice {
        {
            -- These settings are present for all options
            doc = "Choose appropriate memory model",
            defines = "USE_MEMORY",
            source = "common.c"
        },
        tiny = {
            -- These settings only apply to "tiny"
            doc = "For less than 1MB",
            defines = "SETTING=1",
            source = "src/tiny.c"
        },
        large = {
            -- These settings only apply to "large"
            doc = "For more than 1MB",
            defines = "SETTING=2",
            source = "src/large.c"
        }
    }
}

mylib = library {
    -- name defaults to mylib
    src = files [[ lib1.c lib2.c ]],
    defines = myconfig "defines"
}

-- Artifacts use functions to defer referencing seed variables.
-- (referencing seeds by name is one reason to define separately)
mymain = executable {
    source = {
        'common.c',
        'mymain.c',
        myconfig "source"
    },
    defines = {myconfig "defines"},
    lib = {mylib, "c", "c++"}
}

export {myconfig, mylib, mymain}

-- Example tool definitions
gcc5_arm = {
    cc = function(s) return s; end;
    ld = function(s) return s; end;
    ar = function(s) return s; end;
};
clang = {
    cc = function(s) return s; end;
    ld = function(s) return s; end;
    ar = function(s) return s; end;
};
