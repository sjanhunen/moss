-- TODO: prototype the equivalent of seed.mk here in lua

function options(t)
    return function(o) return t[o] end
end

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
    },
    myflag = {
        doc = {
            "Set this for special options",
            yes="Enable special mode one",
            no="Enable special mode two"
        },
        -- This special options "constructor" could return an
        -- anonymous fuction that switches based upon config.
        defines = options{
            yes='special1',
            no='special2'
        },
        -- Another way to define options without "constructor"
        source = {
            'common.c',
            yes = 'src1.c',
            no = 'src2.c'
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
print(seed.myflag.doc[1]);
print(seed.myflag.defines('yes'));
print(multilineRecipe);
