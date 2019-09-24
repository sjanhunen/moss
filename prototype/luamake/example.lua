require("build")
require("gene")

-- Fundamental concepts:
--  artifact - a single fully realized build product
--  table - set of key value pairs used to define an artifact
--  template - a recipe with associated rule required to build one artifact
--  build - set or subseet of artifacts defined within a makefile
--
-- Genetic analogy:
--  table (dna) -> mutation (mutate) -> table (dna)
--  table (dna) -> template (transcribe) -> recipe (rna)
--  recipe (rna) -> tool (translate) -> artifact (proteins)
--
--  Template rules are used to contol when recipes are expanded and tools are
--  invoked.
--
--  Templates are composed and configured using tables and mutations.  Rules
--  and recipes are only expanded when artifacts are actuall built by make.
--
--  Lua modules for gmake (luamake) are primarily intended to assist with
--  modular table definitions, mutations, and namespace management.  Definition
--  of builds and artifacts will still be done within makefiles.

-- TODO: implement gene sequence
function sequence(def)
    return {}
end

-- TODO: refactor gene as mutation
mutation = gene

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

arch_arm = sequence(
    clang.cc, clang.ld, clang.armcm4, clang.fpu, clang.thumb)
arch_x86 = sequence(
    clang.cc, clang.ar, clang.x86_64, clang.fpu)

arm_exe = function(def) return executable(sequence(arch_arm, def)) end
arm_bin = function(def) return executable() end
host_exe = function(def) return executable(sequence(arch_x86, def)) end

concept = build {
    arm = build {
        ["my_app.elf"] = arm_exe(my_app { logging = n, fast = y });
        ["my_app.bin"] = arm_bin("my_app.elf");
    };
    host = build {
        my_app = host_exe(my_app { logging = y, fast = n });
    };
};
