-- Key design points for artifacts:
--  Artifacts are leaf nodes within moss.
--  An artifact is never a parent.
--  An artifact is not a build.
--  Artifacts to not define the filename of the final output.
--
-- Example 1:
--  artifact(op1, op2, ... opn) { k1 = v1; k2 = v2; k3 = v3 }
-- Returns a function that applies operators to an artifact, returning a copy.
--
-- Example 2:
--  artifact(op1, op2, ... opn) { k1 = v1; k2 = v2; k3 = v3 }
-- Returns an artifact.

require("gene")

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
