require("lambda")

local IS_ARTIFACT = {}

function artifact(...)
    local pipeline = {...}

    return function(leaf)
        leaf = deepcopy(leaf)
        
        leaf[IS_ARTIFACT] = true

        for i,step in ipairs(pipeline) do
            leaf = step(leaf);
        end
        return leaf;
    end
end

function isartifact(node)
    return type(node) == "table" and node[IS_ARTIFACT] == true
end
