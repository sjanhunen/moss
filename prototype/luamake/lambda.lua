function lambda(op)
    return function(bt)
        -- TODO: Apply recursively for nested builds
        -- TODO: clone table items before applying
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
