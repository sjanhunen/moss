-- TODO: prototype the equivalent of seed.mk here in lua

seed = {
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
            -- A way to describe conditionals within seeds
            source =
                function(o)
                    if(o.setting == '1') then
                        return 'one.c'
                    else
                        return 'two.c'
                    end
                end
        }
    }
}

artifact = {
    -- A way to describe conditionals within seeds
    source = function(o) return o.src end
}

-- If a table entry is a function, it is evaluated with configuration
-- table passed into it

multilineRecipe = [[
this is a template
with 
multiple lines
]]

-- Print different elements of the struct
print(seed.arch.armv5.source);
print(seed.arch.x86.source({}));
print(multilineRecipe);
