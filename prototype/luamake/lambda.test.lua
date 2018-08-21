require("lambda")
require("build")

describe("lambda", function()
    local replace = function(value)
        return function(entry)
            return value
        end
    end
    local substitute = function(match, replace)
        return function(entry)
            entry[1] = entry[1]:gsub(match, replace)
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
        local fn = lambda { name = substitute("before", "after") }
        local output = fn(input)
        assert.are.same({"before"}, input.name)
        assert.are.same({"after"}, output.name)
    end)
    it("recursively applies operation to nested tables", function()
        local input = {
            name = { "before1" };
            { name = { "before2" } };
            { name = { "before3" } };
        }
        local fn = lambda { name = substitute("before", "after") }
        local output = fn(input)
        assert.are.same({ "after1" }, output.name)
        assert.are.same({ "after2" }, output[1].name)
        assert.are.same({ "after3" }, output[2].name)
        assert.are.same({ "before1" }, input.name)
        assert.are.same({ "before2" }, input[1].name)
        assert.are.same({ "before3" }, input[2].name)
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
