require("build")
require("mutation")

--  Lua modules for gmake (luamake) are primarily intended to assist with
--  modular table definitions, mutations, and namespace management.  Definition
--  of builds and artifacts will still be done within makefiles.

-- TODO: remove alias once we refactor build
compose = build

-- TODO: actually implement these tables with templates
executable = mutation {}
binary = mutation {}
static_lib = mutation {}

my_app = {
    src = {"main.c", "aux.c"},
    defines = "MY_OPTION"
}

clang = {
    cc = {};
    ld = {};
    armcm4 = { cflags = append "-march=arm" };
    thumb = { cflags = append "-thumb2" };
    x86_64 = { cflags = append "-march=x86" };
    fpu = { cflags = append "-fpu" };
}

arm_tools = compose(clang.cc, clang.ld, clang.armcm4, clang.fpu, clang.thumb)
host_tools = compose(clang.cc, clang.ar, clang.x86_64, clang.fpu)

stuff = {
    bin = {
        target = {
            ["app.elf"] = compose(arm_tools, my_app) { logging = n, fast = y },
            ["app.bin"] = compose(arm_tools, binary) { exename = "my_app.elf" },
        },
        host = {
            ["app.exe"] = compose(host_tools, my_app) { logging = y, fast = n },
        }
    }
}

dumpbuild(stuff)