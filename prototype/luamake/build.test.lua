require("build")

describe("Moss build pipeline", function()
    describe("append", function()
        it("creates list from nil list", function()
            local item = "BOB"
            local updated = append(nil, item)
            assert.are.same({item}, updated)
        end)
        it("appends to empty list", function()
            local original = {}
            local item = "BOB"
            local updated = append(original, item)
            assert.are.same({item}, updated)
            assert.are.same({}, original)
        end)
        it("appends to non-empty list", function()
            local item1 = "BOB"
            local item2 = "LARRY"
            local original = {item1}
            local updated = append(original, item2)
            assert.are.same({item1, item2}, updated)
            assert.are.same({item1}, original)
        end)
    end)
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
        it("deep clones build table", function()
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
