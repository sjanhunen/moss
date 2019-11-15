function dumptable(bt, tablename)
    local tabledef = {}
    local output = {}

    for k, v in pairs(bt) do
        if type(k) == "string" then
            if type(v) == "table" then
                if #v > 0 then
                    -- This is an ordered list value
                    table.insert(tabledef, "$1." .. k .. " = " .. table.concat(v, " "))
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
                table.insert(tabledef, "$1." .. k .. " = " .. tostring(v))
            end
        end
    end

    if tablename and #tabledef > 0 then
        table.insert(output, "define " .. tablename)
        table.insert(output, table.concat(tabledef, "\n"))
        table.insert(output, "endef")
    end

    return table.concat(output, "\n")
end

function luafile(name)
    defs = require(name)
    return dumptable(defs)
end