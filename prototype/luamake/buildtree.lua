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

--
-- A compact approach to build tree that makes things very explicit
--

-- If we built this outside a directory, we would build in place
main_image = build "executable" {
    name = "main.exe";
    -- could even customize tools & genes here
    tools = {};
};

-- Build structures used to explicitly define everything that is created
-- A directory artifact without name could imply current directory
build "directory" {
    name = "output";
    tools = { clangld, clangcc };

    myconfig {
        memory_model = "large";
        debug = false;
    };

    build "directory" {
        name = "debug";
        clang_config {
            cc = { cflags = "-Og -DDEBUG" };
        };

        main_image;
    };
    build "directory" {
        name = "release";
        clang_config {
            cc = { cflags = "-O3" };
        };
        myconfig { debug = true };

        main_image;
    };

    build "directory" {
        name = "package";
        tools = { gzip };

        build "zipfile" {
            name = "release.zip";
            source = { main_image, "help.doc", "release-notes.txt" };
        };
    }
};
