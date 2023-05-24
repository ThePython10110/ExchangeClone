function exchangeclone.read_orb_charge(itemstack, user, pointed_thing)
    local stored = itemstack:get_meta():get_int("stored_charge") or 0
    minetest.chat_send_player(user:get_player_name(), "Current Charge: "..stored)
    return itemstack
end

minetest.register_tool("exchangeclone:exchange_orb", {
    description = "Exchange Orb\nCurrent Charge: 0",
    inventory_image = "exchangeclone_exchange_orb.png",
    energy_value = 33792,
    on_use = exchangeclone.read_orb_charge,
})

local recipe_item_1 = "default:steel_ingot"
local recipe_item_2 = "default:diamond"

if exchangeclone.mineclone then
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
	burntime = 1600 --Basically 2 coal blocks
})