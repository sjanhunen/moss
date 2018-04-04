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

mylib = library {
    name = "mycore",
    src = files [[ lib1.c lib2.c ]],
    defines = myconfig('option1')
}

platform {
    -- We can specify options as named table entries
    name = "host",

    -- This platform may be built across these tool settings 
    variants = {gcc_debug, gcc_release, clang_debug},

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

a = files [[ src1.c src2.c src3.c ]]
