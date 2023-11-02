exchangeclone = {recipes = {}}

local old_func = minetest.register_craft
function minetest.register_craft(arg)
    if arg.output then
        exchangeclone.recipes[arg.output] = exchangeclone.recipes[arg.output] or {}
        table.insert(exchangeclone.recipes[arg.output], table.copy(arg))
    end
    old_func(arg)
end