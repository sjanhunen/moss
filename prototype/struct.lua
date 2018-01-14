-- Sanity checks on seed definition can be done here
function seed(s)
    -- Probably return a fuction that takes config as argument
    return s
end

-- Artifact configuration seed defined entirely as table
settings = seed {
    -- A flag that is simply present or absent
    debug = {
        doc = "Set this to enable debug",
        defines = "DEBUG=1",
        source = "src/debug/special.c"
    },
    -- A option that is selected from one of many 
    -- This approach results in some repetition
    eval_mode = {
        doc = {
            "Set this for special mode options",
            lazy="Enable special mode one",
            hard="Enable special mode two"
        },
        defines = {
            lazy='special1',
            hard='special2'
        },
        source = {
            'common.c',
            lazy = 'src1.c',
            hard = 'src2.c'
        },
    },
    -- A option that is selected from one of many
    -- We repeat not the options but the definitions
    -- But this approach is more granular for extension
    memory_model = {
        {
            -- These settings are present for all options
            doc = "Choose appropriate memory model",
            defines = "USE_MEMORY",
            source = "common.c"
        },
        tiny = {
            doc = "For less than 1MB",
            defines = "SETTING=1",
            source = "src/tiny.c"
        },
        large = {
            doc = "For more than 1MB",
            defines = "SETTING=2",
            source = "src/large.c"
        }
    }
}


-- Config table is used to create variables from seed
config = {
    debug = 'Y',
    eval_mode = 'lazy',
    memory_model = 'large'
}

function eval(t)
    -- TODO: aggregate variable across all instances of variable in seed
    return function(setting, config)
        if type(setting[t]) == 'table' then
            return setting[t][config]
        elseif type(setting[t]) ~= nil then
            if config then
                return setting[t]
            end
        end

        return nil
    end
end

-- Sanity checks would take place here
function executable(t)
    return t
end

-- Artifacts can use functions to defer referencing seed variables
main = executable {
    seed = settings,
    source = {
        'common.c',
        'main.c',
        eval('source')
    },
    defines = eval('defines')
}

-- Print different elements of the struct
print(settings.debug.doc);
print(settings.debug.source);
print(settings.eval_mode.doc[1]);
print(settings.eval_mode.defines.lazy);

print(main.source[3](settings.debug, config.debug))
