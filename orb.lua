function read_orb_charge(itemstack, user, pointed_thing)
    local stored = itemstack:get_meta():get_int("stored_charge") or 0
    minetest.chat_send_player(user:get_player_name(), "Current Charge: "..stored)
    return itemstack
end

minetest.register_tool("element_exchange:exchange_orb", {
    description = "Exchange Orb",
    inventory_image = "ee_exchange_orb.png",
    on_use = read_orb_charge,
})

minetest.register_craft({
    type = "shaped",
    output = "element_exchange:exchange_orb",
    recipe = {
        {"default:glass", "default:diamond","default:glass"},
        {"default:diamond", "default:steel_ingot", "default:diamond"},
        {"default:glass", "default:diamond",  "default:glass"}
    }
})
