function append(item)
    return function(list)
        if list == nil then
            list = {}
        end
        table.insert(list, item)
        return list
    end
end
