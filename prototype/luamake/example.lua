--  Lua modules for gmake (luamake) are primarily intended to assist with
--  modular table definitions, mutations, and namespace management.  Definition
--  of builds and artifacts will still be done within makefiles.

exe_template = [[ ${name}: ${obj}; ${tool.ld} -o $@ $< ]]

-- TODO: actually implement these tables with templates
executable = compose { templates = exe_template }
binary = {}
static_lib = {}

my_app = executable {
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

-- Compose functions to create appropriate building blocks
arm_tools = compose(clang.cc, clang.ld, clang.armcm4, clang.fpu, clang.thumb)
host_tools = compose(clang.cc, clang.ar, clang.x86_64, clang.fpu)
arm_app = compose(arm_tools, my_app)
host_app = compose(host_tools, my_app)
arm_bin = compose(arm_tools, binary)

stuff = {
    bin = {
        target = {
            ["app.elf"] = arm_app { logging = n, fast = y },
            ["app.bin"] = arm_bin { exename = "my_app.elf" },
        },
        host = {
            ["app.exe"] = host_app { logging = y, fast = n },
        }
    }
}

return dumpbuild(stuff)