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

-- Consider merting variant concept into platform for an overall concept of
-- nestable build tree?  Any number of required permutations could be easily
-- created this way.
build = variant;

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

-- Perhaps the core concepts become:
-- - artifact: product of build
-- - tool: produce artifacts
-- - seed: core unit of definition for artifacts & tools
-- - build: build tree with common tools (can be nested)

-- All artifacts are created within a build tree using seeds and tools.
build {
    -- This name determines the top-level build output directory
    -- (omitting this results in an in-place build)
    name = "build";

    -- Common seed configuration for all builds
    myconfig {
        memory_model = "large";
        debug = false;
    };

    -- This artifact is built for host-sim, target/debug, target/release
    -- (tools and config differ within each build subtree)
    artifacts = { mymain };

    build {
        name = "host-sim";
        tools = { clang };

        -- Configuration
        myconfig { debug = true };
        clang.cc { cflags = "-fsanitize=address -DDEBUG" };
    };

    build {
        name = "target";
        tools = { gcc5_arm };

        build {
            name = "debug";
            myconfig { debug = true };
            gcc5_arm.cc { cflags = "-Og -DDEBUG" };
        };
        build {
            name = "release";
            gcc5_arm.cc { cflags = "-O3" };
            build {
                -- mylib for target.release requires different cflags
                gcc5_arm.cc { cflags = "-O1" };
                artifacts = mylib;
            };
        };
    };
};
