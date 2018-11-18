-- A gene is the lowest level building block used to create software build products.
-- It is defined through a structure of pairs that ultimately express an artifact.
--
-- Example: definition of gene with parameter pairs only
--  g1 = gene { p1 = "file.c", p2 = "name" }
--
-- Example: definition of gene with operator pairs (op1/op2 are functions)
-- 	g2 = gene { p1 = op1; p2 = op2 }
--
-- A pair operator transforms the parameter to which it has been assigned.
-- A pair definition sets the parameter to which it has been assigned.
--
-- Genes can be composed to create more complex gene sequences.
-- The order of genes in a sequence is significant.
-- This is because operators are not guaranteed to be commutative.
--
-- Example: composition of genes
--  g4 = gene(g1, g2, g3)
--
-- This returns a function that may be evaluated as follows
--
--  g4(<defn>) or g4 { <defn> }
--
-- Sequences may be composed with other genes and sequences.
--

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
