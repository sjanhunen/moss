require("mutation")

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

function dumpbuild(bt, depth)
    if depth == nil then
        depth = 0
    end
    local prefix = " "

    depth = depth + 1
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
                    print(prefix:rep(depth) .. "- " .. k .. ": {" .. txt .. "}")
                else
                    -- This is a nested table value
                    print(prefix:rep(depth) .. "+ " .. k .. ":")
                    dumpbuild(v, depth)
                end
            else
                -- This is a string value
                print(prefix:rep(depth) .. "- " .. k .. ": " .. tostring(v))
            end
        end
    end
end
