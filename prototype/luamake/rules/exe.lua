local rule = require("rule")
local exe = {}

-- TODO: figure out how to formalize definition of options like
-- this with documentation. Should these be traits?
exe.flags = {}
exe.recipe = {}

exe.rule = rule.form(function(bt)
    return bt[exe.recipe]
end)

return exe
