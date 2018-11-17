-- Key design points for artifacts:
--  Operators are functions that operate on artifacts.
--  Operators can be applied to a single artifact or recursively for a whole build.
--  Operators are composed using a series of transformation primitives.
--
-- Example transformations:
--  * addprefix(prefix) - to string
--  * addsuffix(suffix) - to string
--  * append(item) - append item after end of list (table)
--  * prepend(item) - insert item at beginning of list (table)
--  * set(item) - sets the item (replacing all other values)

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

function gene(operation)
    return function(bt)
        return apply(bt, operation)
    end
end

function append(item)
    return function(list)
        if list == nil then
            list = {}
        end
        if type(list) ~= "table" then
            list = { list }
        end
        table.insert(list, item)
        return list
    end
end

function addprefix(prefix)
    return function(str)
        if str == nil then
            return prefix
        else
            return prefix .. str
        end
    end
end

function set(value)
    return function(str)
        return value
    end
end
