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