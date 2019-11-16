require("compose")
require("mutation")

local function dumptable(bt, tablename)
    local tabledef = {}
    local output = {}
    local prefix = ""

    if tablename then
        prefix = "$1."
    end

    for k, v in pairs(bt) do
        if type(k) == "string" then
            if type(v) == "table" then
                if #v > 0 then
                    -- This is an ordered list value
                    table.insert(tabledef, prefix .. k .. " = " .. table.concat(v, " "))
                else
                    if tablename then
                        -- This is a nested definition
                        table.insert(output, dumptable(v, tablename .. "/" .. k))
                    else
                        -- This is a top-level definition
                        table.insert(output, dumptable(v, k))
                    end
                end
            else
                -- This is a string value
                table.insert(tabledef, prefix .. k .. " = " .. tostring(v))
                -- TODO: think about how we can support multi-line string definitions
                -- at the top-level and avoid multi-line problems within tables
            end
        end
    end

    if #tabledef > 0 then
        if tablename then
            table.insert(output, "define " .. tablename)
            table.insert(output, table.concat(tabledef, "\n"))
            table.insert(output, "endef")
        else
            table.insert(output, table.concat(tabledef, "\n"))
        end
    end

    return table.concat(output, "\n")
end

function luafile(name)
    return dumptable(require(name))
end
