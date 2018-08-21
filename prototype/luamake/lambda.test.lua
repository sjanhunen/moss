require("lambda")
require("build")

describe("lambda", function()
    local set = function(value)
        return function(entry)
            return value
        end
    end
    it("applies single operation", function()
        local fn = lambda { name = set("after") }
        local output = fn { name = "before" }
        assert.are.same("after", output.name)
    end)
end)

describe("append", function()
    it("creates list from nil list", function()
        local item = "BOB"
        local list = append(item)(nil)
        assert.are.same({item}, list)
    end)
    it("appends to empty list", function()
        local item = "BOB"
        local list = append(item)({})
        assert.are.same({item}, list)
    end)
    it("appends to non-empty list", function()
        local item1 = "BOB"
        local item2 = "ALICE"
        local list = append(item2)({item1})
        assert.are.same({item1, item2}, list)
    end)
    it("appends to non-list", function()
        local item1 = "BOB"
        local list = append(item2)(item1)
        assert.are.same({item1, item2}, list)
    end)
end)
