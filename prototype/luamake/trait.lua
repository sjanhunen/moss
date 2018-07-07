-- Traits enable modular and granular parameterization of builds.  A trait is a
-- function that transforms parameters => build variables.  Traits implement
-- explicit rules to compose variables and resolve conflicts.

trait = function(arg)
    return function(param, vars) return arg; end
end

-- Variable
opt1 = trait { defines = "$*" };

-- Switch
opt2 = trait { defines = "SET_OPTION" };

-- Choice
opt3 = trait {
    one = { defines = "OPTION_ONE" },
    two = { defines = "OPTION_TWO" }
    };

-- Composition
opt4 = trait {
    option_a = opt1,
    option_b = opt2,
    option_c = opt3
};

-- The traits can be composed into a build variable table as follows
local var = opt1({});
var = opt2({}, var);
var = opt3({}, var);

myconfig = trait {
    -- A flag that is simply present or absent
    debug = trait {
        doc = "Set this to enable debug",
        -- These are only present if flag is true
        defines = "DEBUG=1",
        source = "src/debug/special.c"
    },
    memory_model = trait {
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
