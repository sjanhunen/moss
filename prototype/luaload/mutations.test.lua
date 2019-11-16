require("mutations")

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

describe("addprefix", function()
    it("prefixes nil string", function()
        result = addprefix("pre")(nil)
        assert.are.same("pre", result)
    end)
    it("prefixes valid string", function()
        result = addprefix("pre")("fix")
        assert.are.same("prefix", result)
    end)
end)
