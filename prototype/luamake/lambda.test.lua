require("lambda")

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
end)
