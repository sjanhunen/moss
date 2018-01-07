-- TODO: prototype the equivalent of seed.mk here in lua

config = {
    arch = {
        armv5 = {
            defines = 'UTIL',
            source = [[
                file1.c
                file2.c
                file5.c
                ]]
        },
        x86 = {
            defines = 'INTEL',
            source = [[
                x86.c,
                util.c
                ]]
        }
    }
}

multilineRecipe = [[
this is a template
with 
multiple lines
]]

-- Print different elements of the struct
print(config.arch.armv5.source);
print(multilineRecipe);
