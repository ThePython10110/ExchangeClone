local S = minetest.get_translator()

local function infinite_food_function(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    local original = ItemStack(itemstack)
    if click_test ~= false then
        return click_test
    end
    local player_energy = exchangeclone.get_player_energy(player)
    if player_energy >= 64 then
        local hunger_restore = minetest.item_eat(8, original)
        hunger_restore(itemstack, player, pointed_thing)
    end
    return nil
end

minetest.register_tool("exchangeclone:infinite_food", {
    description = S("Infinite Food").."\n"..S("Consumes 64 energy when eaten"),
    groups = { food = 2, eatable = 8, disable_repair = 1, fire_immune = 1},
    on_place = infinite_food_function,
    on_secondary_use = infinite_food_function,
    _mcl_saturation = 12.8,
})

minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, player, pointed_thing)
    local player_energy = exchangeclone.get_player_energy(player)
    if itemstack:get_name() == "exchangeclone:infinite_food" then
        exchangeclone.set_player_energy(player, player_energy - 64)
    end
end)