require("artifact")
require("lambda")

describe("artifact", function()
    describe("artifact()", function()
        it("returns a function", function()
            local a = artifact()
            assert.are.same("function", type(a))
        end)

        it("operates on a copy of table", function()
            local a = artifact()
            local node = { a = 1, b = 2 }
            local result = a(node)
            node.a = 5
            node.b = 6
            assert.are.same(1, result.a)
            assert.are.same(2, result.b)
        end)

        it("applies operations to table", function()
            local op1 = lambda({ bob = set(1) })
            local op2 = lambda({ alice = set(2) })
            local node = artifact(op1, op2) { larry = 3 }
            assert.are.same(1, node.bob)
            assert.are.same(2, node.alice)
            assert.are.same(3, node.larry)
        end)
    end)

    describe("isartifact()", function()
        it("returns false for nil", function()
            assert.are.same(false, isartifact(nil))
        end)

        it("returns false for object", function()
            assert.are.same(false, isartifact({}))
        end)

        it("returns true for object", function()
            a = artifact() {}
            assert.are.same(true, isartifact(a))
        end)
    end)
end)
