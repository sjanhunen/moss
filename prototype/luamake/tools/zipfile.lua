local rule = require("rule")

local ziptool = "zip.exe"

return rule.form("${ziptool} $@ $<")
