-- A rule defines how build artifacts are created with a particular tool.  This
-- concept will replace tools + artifacts and streamline the design.

function rule(traits)
    return function(args) return args; end
end

-- We probably want to support traits that have fixed parameters like this
toolconfig = trait {
    cflags = "-Wall",
    objext = ".obj"
};

-- Translation rule for cpp files
myccompiler = rule(toolconfig) {
    -- Creates an implicit rule to transform source -> object using recipe
    object = ".o",
    source = ".cpp",
    -- This recipe is passed directly to make after expanding any build variables
    -- Traits passed into rule are injected into build variables
    recipe = [[ cc -o $@ ${cflags} -Mext=.d $^ ]]
};

-- Forming rule for static libraries 
mystaticlib = rule(toolconfig) {
    -- Target name is derived from prefix + name + suffix
    prefix = "lib",
    suffix = ".a",
    -- Objects are derived from source files using translation rules
    translate = myccompiler,
    -- This recipe is passed directly to make after expanding any build variables
    -- Traits passed into rule are injected into build variables
    recipe = [[ 
        ar -o $@ $<
    ]]
};
