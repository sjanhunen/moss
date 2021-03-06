--  Lua module loader for gnumake (luaload) is intended to assist with modular
--  table definitions, mutations, and namespace management.  Definition of
--  build rules and templates will still be done within makefiles.

-- Actual templates are defined in makefiles
executable = compose { templates = exe_template }
binary = compose { templates = bin_template }

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

return {
    hello = "Hello World!",
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
