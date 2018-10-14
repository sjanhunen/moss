require("lambda")

local ARTIFACT = {}

function artifact(...)
    local pipeline = {...}

    return function(leaf)
        leaf = deepcopy(leaf)
        
        leaf[ARTIFACT] = true

        for i,step in ipairs(pipeline) do
            leaf = step(leaf);
        end
        return leaf;
    end
end

function isartifact(node)
    return type(node) == "table" and node[ARTIFACT] == true
end
