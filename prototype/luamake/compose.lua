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

local function deepcopy(bt)
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

local function shallowcopy(bt)
    local copy = {}
    for k, v in pairs(bt) do
        copy[k] = v
    end
    return copy
end

local function apply(bt, operation)
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