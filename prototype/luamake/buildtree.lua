-- Moss favors explicit definition over automatic discovery.
-- The build tree is a structure used to explicitly define how software is built.
-- This is in contrast to tools like autoconf that attempt to discover aspects of this.

function build(v)
    if(v.name) then
        print("build: " .. v.name);
    else
        print("anonymous build");
    end
    return function(e) return v end
end

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
