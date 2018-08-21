require("lambda")
require("build")

describe("lambda", function()
    local replace = function(value)
        return function(entry)
            return value
        end
    end
    local set = function(value)
        return function(entry)
            entry[1] = value
            return entry
        end
    end
    it("applies single operation", function()
        local fn = lambda { name = replace("after") }
        local output = fn { name = "before" }
        assert.are.same("after", output.name)
    end)
    it("copies build table before applying operation", function()
        local input = { name = "before" }
        local fn = lambda { name = replace("after") }
        local output = fn(input)
        assert.are.same("before", input.name)
        assert.are.same("after", output.name)
    end)
    it("copies table member before applying operation", function()
        local input = { name = { "before" } }
        local fn = lambda { name = set("after") }
        local output = fn(input)
        assert.are.same({"before"}, input.name)
        assert.are.same({"after"}, output.name)
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
