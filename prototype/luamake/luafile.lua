function dumptable(bt, tablename)
    local tabledef = {}
    -- TODO: use some type of string buffer or memory file instead
    -- of just repeatedly concatenating strings!
    local output = ""

    for k, v in pairs(bt) do
        if type(k) == "string" then
            if type(v) == "table" then
                local txt = "" 
                for i,p in ipairs(v) do
                    if type(p) == "string" then
                        txt = txt .. "'" .. tostring(p) .. "',"
                    else
                        txt = txt .. tostring(p) .. ","
                    end
                end
                if txt:len() > 0 then
                    -- This is an ordered list value
                    table.insert(tabledef, "$1." .. k .. " = " .. txt)
                else
                    -- This is a nested definition
                    if tablename then
                        output = output .. dumptable(v, tablename .. "/" .. k)
                    else
                        output = output .. dumptable(v, k)
                    end
                end
            else
                -- This is a string value
                table.insert(tabledef, "$1." .. k .. " = " .. tostring(v))
            end
        end
    end

    if tablename and #tabledef > 0 then
        output = output .. "define " .. tablename .. "\n"
        for i,line in ipairs(tabledef) do
            output = output .. line .. "\n"
        end
        output = output .. "endef" .. "\n"
    end

    return output
end

function luafile(name)
    defs = require(name)
    return dumptable(defs)
end