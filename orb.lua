function read_orb_charge(itemstack, user, pointed_thing)
    local stored = itemstack:get_meta():get_int("stored_charge") or 0
    minetest.chat_send_player(user:get_player_name(), "Current Charge: "..stored)
    return itemstack
end

minetest.register_tool("exchangeclone:exchange_orb", {
    description = "Exchange Orb",
    inventory_image = "ee_exchange_orb.png",
    on_use = read_orb_charge,
})

local recipe_item_1 = "default:steel_ingot"
local recipe_item_2 = "default:diamond"
local recipe_item_3 = "default:glass"

if exchangeclone.mineclone then
    recipe_item_1 = "mcl_core:iron_ingot"
    recipe_item_2 = "mcl_core:diamond"
    recipe_item_3 = "mcl_core:glass"
end

minetest.register_craft({
    type = "shaped",
    output = "exchangeclone:exchange_orb",
    recipe = {
        {recipe_item_3, recipe_item_2, recipe_item_3},
        {recipe_item_2, recipe_item_1, recipe_item_2},
        {recipe_item_3, recipe_item_2,  recipe_item_3}
    }
})
