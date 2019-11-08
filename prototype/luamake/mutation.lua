-- A mutation is a function that is used to transform a table definition in some way.
--
-- Example: definition of mutation with operator pairs (op1/op2 are functions)
-- 	g2 = mutation { p1 = op1; p2 = op2 }
--
-- Example: definition of mutation with parameter pairs only
--  g1 = mutation { p1 = "file.c", p2 = "name" }
--
-- A pair operator transforms the parameter to which it has been assigned.
-- A pair definition sets the parameter to which it has been assigned.
--
-- mutations can be composed to create more complex mutation sequences.
-- The order of mutations in a sequence is significant.
-- This is because operators are not guaranteed to be commutative.
--
-- Example: composition of mutations
--  m4 = mutation(m1, m2, m3)
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

function mutation(operation)
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
