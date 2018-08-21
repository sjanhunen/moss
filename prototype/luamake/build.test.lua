require("build")

describe("Moss build pipeline", function()
    describe("extend", function()
		it("creates non-existant variables", function()
			local result = extend("FLAG", "1") {}
			assert.are.same({FLAG=" 1"}, result)
		end)
		it("appends to existing variables", function()
			local result = extend("FLAG", "2") { FLAG = "1" }
			assert.are.same({FLAG="1 2"}, result)
		end)
	end)
    describe("build", function()
        it("composes two functions", function()
            local f1 = extend("F", "1")
            local f2 = extend("F", "2")
            local result = build(f1, f2) { F = "0" }
            assert.are.same({F = "0 1 2"}, result)
        end)
        it("deep copies build table", function()
            local expected = {
                { f = "a" };
                { f = "b" };
            }

            local nested1 = { f = "a" }
            local nested2 = { f = "b" }

            local actual = build()({
                nested1;
                nested2;
            })
            assert.are.same(expected, actual)

            nested1.f = "e"
            nested2.f = "f"
            assert.are.same(expected, actual)
        end)
    end)
end)
