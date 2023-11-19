exchangeclone = {recipes = {}}

local old_func = minetest.register_craft
function minetest.register_craft(arg, ...)
    if arg and arg.output then
        local itemstring = ItemStack(arg.output):get_name()
        exchangeclone.recipes[itemstring] = exchangeclone.recipes[itemstring] or {}
        table.insert(exchangeclone.recipes[itemstring], table.copy(arg))
        --[[ -- reverse cooking recipes too
        if arg.type == "cooking" then
            itemstring = ItemStack(arg.recipe):get_name()
            local reverse_arg = table.copy(arg)
            reverse_arg.recipe, reverse_arg.output = reverse_arg.output, reverse_arg.recipe
            exchangeclone.recipes[itemstring] = exchangeclone.recipes[itemstring] or {}
            table.insert(exchangeclone.recipes[itemstring], table.copy(reverse_arg))
        end --]]
    end
    old_func(arg, ...)
end

if minetest.get_modpath("technic") then
    local function register_technic_recipe(recipe)
        local result = {recipe = recipe.input, output = recipe.output, type = "technic"}
        local output_itemstring = ItemStack(recipe.output):get_name()
        exchangeclone.recipes[output_itemstring] = exchangeclone.recipes[output_itemstring] or {}
        table.insert(exchangeclone.recipes[output_itemstring], result)
    end
    function exchangeclone.register_technic_recipe(typename, recipe)
        local data = technic.recipes[typename]
        if (data.output_size == 1) then
            if data.output_size == 1 then
                register_technic_recipe(table.copy(recipe))
            end
        end
    end
end