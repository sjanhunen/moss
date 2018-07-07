build = require("build")

describe("Moss build pipeline", function()
	describe("extend", function()
		it("should create non-existant variables", function()
			local result = extend("FLAG", "1") {}
			assert.are.same({FLAG=" 1"}, result)
		end)
		it("should append to existing variables", function()
			local result = extend("FLAG", "2") { FLAG = "1" }
			assert.are.same({FLAG="1 2"}, result)
		end)
	end)
end)
