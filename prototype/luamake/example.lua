require("build")
require("gene")

-- Fundamental concepts:
--  artifact - a fully realized build product (e.g. output file)
--  definition - set of key value pairs that define an artifact
--  transcript - set of rules with recipes required to build one artifact
--
-- Genetic analogy:
--  definition (dna) -> mutation (mutate) -> definition (dna)
--  definition (dna) -> rule (transcribe) -> transcript (rna)
--  transcript (rna) -> build (translate) -> artifact (protein)
--
-- A mutation is a pure function that modifies a definition (mutation.lua)
-- A rule creates a transcript from a definition (rule.lua)
-- A build is used to realize final artifacts by following transcripts (build.lua)

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
