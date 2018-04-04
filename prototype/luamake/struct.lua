-- Terminology Questions:
-- - can we actually use the term seed with moss?
-- - should a seed be called a cell or something else?
-- - should a 'module' actually be a 'spore'?

-- Sanity checks on seed definition can be done here
-- Artifact configuration seed defined entirely as table
settings = seed {
    -- A flag that is simply present or absent
    debug = {
        doc = "Set this to enable debug",
        defines = "DEBUG=1",
        source = "src/debug/special.c"
    },
    -- A option that is selected from one of many 
    -- This approach results in some repetition
    eval_mode = {
        doc = {
            "Set this for special mode options",
            lazy="Enable special mode one",
            hard="Enable special mode two"
        },
        defines = {
            lazy='special1',
            hard='special2'
        },
        source = {
            'common.c',
            lazy = 'src1.c',
            hard = 'src2.c'
        },
    },
    -- A option that is selected from one of many
    -- We repeat not the options but the definitions
    -- But this approach is more granular for extension
    memory_model = {
        {
            -- These settings are present for all options
            doc = "Choose appropriate memory model",
            defines = "USE_MEMORY",
            source = "common.c"
        },
        tiny = {
            doc = "For less than 1MB",
            defines = "SETTING=1",
            source = "src/tiny.c"
        },
        large = {
            doc = "For more than 1MB",
            defines = "SETTING=2",
            source = "src/large.c"
        }
    }
}

-- Seed creation should return a table of functions like so
settings = {
    debug = {},
    eval_mode = {},
    memory_model = {
        doc = {},
        defines = {},
        source = {}
    }
}

-- Artifacts can use functions to defer referencing seed variables
-- (referencing seeds by name is one reason to define separately)
main = executable {
    source = {
        'common.c',
        'main.c',
        settings.memory_model.source
    },
    defines = settings.memory_model.defines
}

gcc_debug = variant {
    cflags = list [[ -DDEBUG=1 -Og ]]
}

clang_debug = variant {
    cflags = list [[ -DDEBUG=1 -Og ]]
}

gcc_release = variant {
    cflags = list [[ -O3 ]]
}

-- Fake out what a seed might be like
myconfig = function(a) return a; end

-- If an artifact doesn't have a name, the name could
-- be based upon the variable name it is assigned to
mylib = library {
    -- name defaults to mylib
    src = files [[ lib1.c lib2.c ]],
    defines = myconfig('option1')
}

-- Variable holding platform could differ from name of
-- platform used within builds.
-- If no platforms are defined, do we just build artifacts?
host = platform {
    -- We can specify options as named table entries
    name = "host-default",

    -- variant may be a property of platform (TBD)
    variants = { gcc_debug, clang_debug, gcc_release },

    -- Setting seed options can be done by invoking the seed by name
    myconfig {
        option1 = "a",
        option2 = "b"
    },

    -- Simply list artifacts that should be built for this platform
    mylib, catch, main,

    -- Create entirely new artifacts just for this platform

    executable {
        name = "bob",
        src = files [[ a.c b.c c.c ]],
        defines = {"RUN_TIME_CHECKS", "COMPILE_TIME_CHECKS"},
        lib = mylib
    },

    executable {
        name = "test-bob",
        src = "test_bob.cpp",
        lib = { mylib, catch }
    }
}

-- Consider declaring variants outside platform at highest level
arm_cortex_cm5 = variant {
    name = "arm-cm5",

    -- Can tool configuration be totally defined by variant?
    cflags = "--arch=arm",
    cdefines = "ARM",
    ldflags = "",

    -- List the platforms to build for this variant
    host, target,

    -- Does it make sense to allow artifacts here directly?
    mylib, main
}

a = files [[ src1.c src2.c src3.c ]]

-- Explicitly define which variables are exported by moss module
-- (only these are visible when the module is imported)
export {mylib, p, a}
