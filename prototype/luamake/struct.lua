-- Terminology Questions:
-- - can we actually use the term seed with moss?
-- - should a seed be called a cell or something else?
-- - should a 'module' actually be a 'spore'?

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
    defines = myconfig "memory_model.defines"
}

-- Artifacts use functions to defer referencing seed variables.
-- Functions are invoked later for each platform to get values.
-- (referencing seeds by name is one reason to define separately)
mymain = executable {
    source = {
        'common.c',
        'mymain.c',
        myconfig "memory_model.source"
    },
    defines = {myconfig "memory_model.defines", myconfig "debug.defines"},
    lib = {mylib, "c", "c++"}
}

-- Variants are used to specialize tool settings
arm_gcc_debug = variant {
    cflags = list [[ -DDEBUG=1 -Og ]]
}
host_clang_debug = variant {
    cflags = list [[ -DDEBUG=1 -Og ]]
}
arm_gcc_release = variant {
    cflags = list [[ -O3 ]]
}

host_test = platform {
    -- A single unnamed variant implies only a single build type
    variants { host_clang_debug },

    myconfig {
        debug = true,
        memory_model = "large"
    },

    -- Simply list artifacts that should be built for this platform
    mymain,

    -- Create entirely new artifact just for this platform
    -- Artifacts mylib and catch are automatically built for this platform
    executable {
        name = "host-test",
        src = "host-test.cpp",
        lib = {mylib, catch, "c++"}
    }
}

target_board = platform {
    -- Multiple named variants implies platform can be built multiple ways
    variants {
        debug = arm_gcc_debug,
        release = arm_gcc_release
    },

    myconfig {
        debug = false,
        memory_model = "large"
    },

    -- Simply list artifacts that should be built for this platform
    -- Think about how we could explicitly link special versions of libraries
    -- with very specific tools settings (e.g. target_lib_fast "mylib" as lib)
    mymain
}

export {myconfig, mylib, mymain}
