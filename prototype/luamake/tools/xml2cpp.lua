local rules = require("rules")

local xml2cpp_tool = "/opt/tool/xml2cpp";

return rules.translate(".xml", ".cpp", "${xml2cpp_tool} -o $@ $^")
