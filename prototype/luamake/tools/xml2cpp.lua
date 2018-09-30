local rule = require("rule")

local xml2cpp_tool = "/opt/tool/xml2cpp";

return rule.translate(".xml", ".cpp", "${xml2cpp_tool} -o $@ $^")
