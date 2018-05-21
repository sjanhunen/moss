-- Moss core concepts:
--  Gene: collection of configurable settings used to specialize build artifact(s)
--  Tool: commands used to translate code or form artifacts
--  Build: a hierarchical structure used to
--      * define and organize the completed artifacts that will be formed
--      * select the tools used to form artifacts
--      * specialize the genes used for forming artifacts within leaves
--  Spore: a collection of genome, process, or build definitions used to create artifacts

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

export {myconfig, mylib, mymain}
