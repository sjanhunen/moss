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
    defines = myconfig "defines"
}

-- Artifacts use functions to defer referencing seed variables.
-- Functions are invoked later for each platform to get values.
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
    mymain { name = "main.elf" }
}

export {myconfig, mylib, mymain}

-- Could we merge variant concept into platform and just create some type of
-- nestable build or variant concept?  Any number of required permutations
-- could be easily created this way.
build = variant;
host_gcc = variant {};
arm_gcc = variant {};

-- Perhaps the core concepts are just seed, artifact, tool, build.
-- A build is a way to combine configuration & tools to create artifacts.
build {
    -- Common seed configuration for all builds
    myconfig {
        memory_model = "large";
        debug = false;
    };

    -- This artifact is built for host-sim, target.debug, target.release
    artifacts = {mymain};

    build {
        name = "host-sim";
        myconfig { debug = true };
        tools = { arm_gcc_debug };
    };

    build {
        name = "target";
        build {
            name = "debug";
            tools = {
                arm_gcc { cflags = [[ DEBUG -Og ]] };
            };
            myconfig { debug = true };
        };
        build {
            name = "release";
            -- Consider nested build environments to specialize artifacts
            build {
                artifacts = mylib;
                tools = {arm_gcc { cflags = [[ -O3 ]] }};
            };
            tools = {
                arm_gcc { cflags = [[ -O3 ]] };
            };
        };
    };
};
