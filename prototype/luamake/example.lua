require("build")
require("gene")

-- Fundamental concepts:
--  artifact - a single fully realized build product
--  definition - set of key value pairs that define an artifact
--  template - set of rules with recipes required to build one artifact
--
-- Genetic analogy:
--  definition (dna) -> mutation (mutate) -> definition (dna)
--  definition (dna) -> template expansion (transcribe) -> rules with recipes (rna)
--  rules with recipes (rna) -> build (translate) -> artifacts (proteins)
--
--  Templates are composed and configured using definitions and mutations.
--  Rules and recipes are only expanded when artifacts are actuall built by make.
--
--  Lua modules for gmake (lmake) are primarily intended to assist with modular
--  definitions, mutations, and namespace management.
--  Definition of builds and artifacts will still be done within makefiles.

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
