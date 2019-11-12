require("compose")
require("mutation")

describe("Moss build compose", function()
    describe("compose", function()
        it("composes two functions", function()
            local f1 = {F = append(1)}
            local f2 = {F = append(2)}
            local result = compose(f1, f2) { F = 0 }
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
end)
