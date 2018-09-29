local rules = require("rules")

local ziptool = "zip.exe"

return rules.form("${ziptool} $@ $<")
