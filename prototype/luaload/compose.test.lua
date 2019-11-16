require("compose")

describe("compose", function()
    local substr = function(match, replace)
        return function(entry)
            return entry:gsub(match, replace)
        end
    end

    local subitems = function(match, replace)
        return function(entry)
            for i,k in ipairs(entry) do
                entry[i] = entry[i]:gsub(match, replace)
            end
            return entry
        end
    end

    it("applies single operation", function()
        local fn = compose { name = substr("before", "after") }
        local output = fn { name = "before" }
        assert.are.same("after", output.name)
    end)

    it("copies build table before applying operation", function()
        local input = { name = "before" }
        local fn = compose { name = substr("before", "after") }
        local output = fn(input)
        assert.are.same("before", input.name)
        assert.are.same("after", output.name)
    end)

    it("copies table member before applying operation", function()
        local input = { name = { "before" } }
        local fn = compose { name = subitems("before", "after") }
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
        local fn = compose { name = subitems("before", "after") }
        local output = fn(input)
        assert.are.same({ "after1" }, output.name)
        assert.are.same({ "after2" }, output[1].name)
        assert.are.same({ "after3" }, output[2].name)
        assert.are.same({ "before1" }, input.name)
        assert.are.same({ "before2" }, input[1].name)
        assert.are.same({ "before3" }, input[2].name)
    end)

    it("composes two functions", function()
        local f1 = {F = function(v) table.insert(v, 1); return v; end}
        local f2 = {F = function(v) table.insert(v, 2); return v; end}
        local result = compose(f1, f2) { F = { 0 } }
        assert.are.same({F = {0, 1, 2}}, result)
    end)

    it("deep copies build table", function()
        local expected = {
            { f = "a" };
            { f = "b" };
        }

        local nested1 = { f = "a" }
        local nested2 = { f = "b" }

        local actual = compose()({
            nested1;
            nested2;
        })
        assert.are.same(expected, actual)

        nested1.f = "e"
        nested2.f = "f"
        assert.are.same(expected, actual)
    end)
end)