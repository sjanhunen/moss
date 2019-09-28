require("build")
require("mutation")

--  Lua modules for gmake (luamake) are primarily intended to assist with
--  modular table definitions, mutations, and namespace management.  Definition
--  of builds and artifacts will still be done within makefiles.

-- TODO: implement this artifact
function executable(def)
    -- Returns rules for cc, ld, and object files
    return function()
        return def
    end
end

-- TODO: implement this artifact
function binary(def)
    -- Returns rules for bin file via objdump
    return function()
        return def
    end
end

-- TODO: implement this artifact
function static_lib(def)
    -- Returns rules for cc, ar, and object files
    return function()
        return def
    end
end

my_app = function(config)
    -- TODO: do something with config
    return {
        src = {"main.c", "aux.c"};
        defines = {"MY_OPTION"};
    }
end

clang = {
    cc = mutation {};
    ld = mutation {};
    armcm4 = mutation { cflags = append "-march=arm" };
    thumb = mutation { cflags = append "-thumb2" };
    x86_64 = mutation { cflags = append "-march=x86" };
    fpu = mutation { cflags = append "-fpu" };
};

arch_arm = mutation(clang.cc, clang.ld, clang.armcm4, clang.fpu, clang.thumb)
arch_x86 = mutation(clang.cc, clang.ar, clang.x86_64, clang.fpu)

arm_exe = function(def) return executable(mutation(arch_arm, def)) end
arm_bin = function(def) return executable() end
host_exe = function(def) return executable(mutation(arch_x86, def)) end

concept = build {
    arm = build {
        ["my_app.elf"] = arm_exe(my_app { logging = n, fast = y });
        ["my_app.bin"] = arm_bin("my_app.elf");
    };
    host = build {
        my_app = host_exe(my_app { logging = y, fast = n });
    };
};
