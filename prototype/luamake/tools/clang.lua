require("operator")
local rule = require("rule")
local clang = {}
local exe = require("rules/exe")

local clang_home = "/opt/bin/clang";

clang.archive = rule.form("${ziptool} $@ $<")

clang.cc = rule.compile(".cpp",
		"${clang_home}/clangcc   		\z
        $(addprefix -D,${defines})   	\z
        $(addprefix -D,${defines})   	\z
        -o $@ $^")

clang.staticlib = rule.form("${clang_home}/clangar $@ $<")

clang.debug = operator {
    cflags = append("-g"),
    [exe.recipe] = set("${clang_home}/clangld $@ $^")
}

clang.release = operator {
    cflags = append("-O3"),
    [exe.recipe] = set("${clang_home}/clangld $@ $^")
}

clang.fpu = operator { cflags = append("-ffpu") }

return clang
