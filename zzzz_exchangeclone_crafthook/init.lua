minetest.log("Wrapping craft function")
exchangeclone = {recipes = {}}

local old_func = minetest.register_craft
function minetest.register_craft(arg, ...)
    if arg and arg.output then
        local itemstring = ItemStack(arg.output):get_name()
        exchangeclone.recipes[itemstring] = exchangeclone.recipes[itemstring] or {}
        table.insert(exchangeclone.recipes[itemstring], table.copy(arg))
    end
    old_func(arg, ...)
end