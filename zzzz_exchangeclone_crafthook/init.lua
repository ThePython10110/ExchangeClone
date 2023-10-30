exchangeclone = {}

local old_func = minetest.register_craft
function minetest.register_craft(...)
    local arg = {...}
    if arg.replacements then
        table.insert(exchangeclone.recipes, table.copy(arg))
    end
    old_func(...)
end