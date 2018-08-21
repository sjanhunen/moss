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

function lambda(op)
    return function(bt)
        -- TODO: Apply recursively for nested builds
        bt = shallowcopy(bt)
        for name,step in pairs(op) do
            bt[name] = step(bt[name])
        end
        return bt;
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
