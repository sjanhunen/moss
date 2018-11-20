-- Key design points for artifacts:
--  Artifacts are leaf nodes within moss.
--  An artifact is never a parent.
--  An artifact is not a build.
--  Artifacts do not define the filename of the final output.
--
-- Gene sequences can be applied to artifacts in place:
--
--  artifact(g1, g2, g3, ...) { <base definition> }
--
-- Base definitions are given for artifacts.
-- Genes are used to manipulate definitions.
--
-- Example 1:
--  executable = artifact(g1, g2, g3, ...);
--
-- Example 2:
--  artifact(g1, g2, ... gn) { k1 = v1; k2 = v2; k3 = v3 };
--
-- Example 3:
--  artifact { k1 = v1; k2 = v2; k3 = v3 }

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
