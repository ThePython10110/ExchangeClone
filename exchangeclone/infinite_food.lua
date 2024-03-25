local S = minetest.get_translator()

local stamina_exists = minetest.get_modpath("stamina")
local stamina_max = minetest.settings:get("stamina.visual_max") or 20

local function infinite_food_function(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    local original = ItemStack(itemstack)
    if click_test ~= false then
        return click_test
    end
    local player_emc = player:_get_emc()
    if player_emc >= 64 then
        if stamina_exists then
            if stamina.get_saturation(player) >= stamina_max then
                return nil
            end
        elseif exchangeclone.mtg and player:get_hp() >= player:get_properties().hp_max then
            return nil
        end
        -- no idea why this is different between games but it works
        local hunger_restore = minetest.item_eat(8, exchangeclone.mcl and ItemStack("") or original)
        hunger_restore(itemstack, player, pointed_thing)
    end
    return nil
end

minetest.register_tool("exchangeclone:infinite_food", {
    description = S("Infinite Food").."\n"..S("Consumes 64 EMC when eaten"),
    wield_image = "farming_bread.png^[colorize:#ffff00:128",
    inventory_image = "farming_bread.png^[colorize:#ffff00:128",
    groups = { food = 2, eatable = 8, disable_repair = 1, fire_immune = 1},
    on_place = exchangeclone.mcl and infinite_food_function,
    on_secondary_use = exchangeclone.mcl and infinite_food_function,
    on_use = (not exchangeclone.mcl) and infinite_food_function,
    _mcl_saturation = 12.8,
})

minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, player, pointed_thing)
    if itemstack:get_name() == "exchangeclone:infinite_food" then
        player:_add_emc(-64)
    end
end)

local bread_itemstring = exchangeclone.itemstrings.bread

minetest.register_craft({
    output = "exchangeclone:infinite_food",
    recipe = {
        {bread_itemstring, bread_itemstring, bread_itemstring,},
        {bread_itemstring, "exchangeclone:transmutation_tablet", bread_itemstring,},
        {bread_itemstring, bread_itemstring, bread_itemstring,},
    }
})