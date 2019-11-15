-- A mutation is a table containing functions used to transform another table.
--
-- Example: definition of mutation with operator pairs (op1/op2 are functions)
-- 	g2 = { p1 = op1; p2 = op2 }
--
-- Example: definition of mutation with parameter pairs only
--  g1 = { p1 = "file.c", p2 = "name" }
--
-- An operator transforms the parameter to which it has been assigned.
-- A definition overwrites the parameter to which it has been assigned.
--
-- Mutations are composed to create final table definitions.
-- The order of mutations in a sequence is significant.
-- This is because operators are not guaranteed to be commutative.
--
-- Example: composition of mutations
--  m4 = compose(m1, m2, m3)
--
-- This returns a function that may be evaluated as follows
--
--  m4(<defn>) or m4 { <defn> }

function deepcopy(bt)
    local copy = {}
    for k, v in pairs(bt) do
        if type(v) == "table" then
            copy[k] = deepcopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function shallowcopy(bt)
    local copy = {}
    for k, v in pairs(bt) do
        copy[k] = v
    end
    return copy
end

function apply(bt, operation)
    bt = shallowcopy(bt)

    -- Apply operation to all entries at this level
    for name,step in pairs(operation) do
        if type(step) ~= "function" then
            -- Values (non functions) are treated as direct assignment
            local contents = step
            step = function() return contents end
        end
        if type(bt[name]) == "table" then
            bt[name] = step(deepcopy(bt[name]))
        else
            bt[name] = step(bt[name])
        end
    end

    -- Apply operation recursively to nested tables
    for i,v in ipairs(bt) do
        if type(v) == "table" then
            bt[i] = apply(v, operation)
        end
    end

    return bt;
end

-- Composes tables and functions into a single function that is retuned.
-- The returned function mutates a build table when called.
function compose(...)
    local pipeline = {...}

    return function(bt)
        bt = deepcopy(bt)
        for i,step in ipairs(pipeline) do
            if type(step) ~= "function" then
                bt = apply(bt, step)
            else
                bt = step(bt);
            end
        end
        return bt;
    end
end

function dumpbuild(bt, tablename)
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
                        output = output .. dumpbuild(v, tablename .. "/" .. k)
                    else
                        output = output .. dumpbuild(v, k)
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