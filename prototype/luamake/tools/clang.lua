require("lambda")
local rules = require("rules")
local clang = {}

local clang_home = "/opt/bin/clang";

clang.archive = rules.form("${ziptool} $@ $<")

clang.cc = rules.compile(".cpp",
		"${clang_home}/clangcc   		\z
        $(addprefix -D,${defines})   	\z
        $(addprefix -D,${defines})   	\z
        -o $@ $^")

clang.executable = rules.form("${clang_home}/clangld $@ $<")

clang.staticlib = rules.form("${clang_home}/clangar $@ $<")

clang.debug = lambda { cflags = append("-g") }
clang.release = lambda { cflags = append("-O3") }
clang.fpu = lambda { cflags = append("-ffpu") }

return clang
