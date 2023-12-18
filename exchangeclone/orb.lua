local S = minetest.get_translator()

local function read_orb_charge(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    local stored = exchangeclone.get_orb_itemstack_energy(itemstack)
    minetest.chat_send_player(player:get_player_name(), S("Current Charge: @1", exchangeclone.format_number(stored)))
    return itemstack
end

minetest.register_tool("exchangeclone:exchange_orb", {
    description = S("Exchange Orb").."\n"..S("Current Charge: @1", 0),
    inventory_image = "exchangeclone_exchange_orb.png",
    color = "#000000",
    on_secondary_use = read_orb_charge,
    on_place = read_orb_charge,
    groups = {exchange_orb = 1, disable_repair = 1, fire_immune = 1}
})

minetest.register_craft({
    type = "shaped",
    output = "exchangeclone:exchange_orb",
    groups = {},
    recipe = {
        {exchangeclone.itemstrings.diamond, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.diamond},
        {exchangeclone.itemstrings.iron, "exchangeclone:philosophers_stone", exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.diamond, exchangeclone.itemstrings.iron,  exchangeclone.itemstrings.diamond}
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})
minetest.register_craft({ -- Making it fuel so MineClone hoppers will work with (de)constructors
	type = "fuel",
	recipe = "exchangeclone:exchange_orb",
	burntime = 24000 --Basically 30 coal blocks...
})