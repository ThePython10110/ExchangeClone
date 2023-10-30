local function read_orb_charge(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    local stored = exchangeclone.get_orb_itemstack_energy(itemstack)
    minetest.chat_send_player(player:get_player_name(), "Current Charge: "..stored)
    return itemstack
end

minetest.register_tool("exchangeclone:exchange_orb", {
    description = "Exchange Orb\nCurrent Charge: 0",
    inventory_image = "exchangeclone_exchange_orb.png",
    energy_value = 33792,
    color = "#000000",
    on_secondary_use = read_orb_charge,
    on_place = read_orb_charge,
    groups = {exchange_orb = 1, disable_repair = 1, fire_immune = 1}
})

local recipe_item_1 = "default:steel_ingot"
local recipe_item_2 = "default:diamond"

if exchangeclone.mcl then
    recipe_item_1 = "mcl_core:iron_ingot"
    recipe_item_2 = "mcl_core:diamond"
end

minetest.register_craft({
    type = "shaped",
    output = "exchangeclone:exchange_orb",
    groups = {},
    recipe = {
        {recipe_item_2, recipe_item_1, recipe_item_2},
        {recipe_item_1, "exchangeclone:philosophers_stone", recipe_item_1},
        {recipe_item_2, recipe_item_1,  recipe_item_2}
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})
minetest.register_craft({ --Making it fuel so hopper will work with constructor better
	type = "fuel",
	recipe = "exchangeclone:exchange_orb",
	burntime = 24000 --Basically 30 coal blocks... it should be worth it.
})