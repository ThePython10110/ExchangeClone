-- next update?

local pages = {}

function exchangeclone.show_guidebook(player)
    
end

minetest.register_tool("exchangeclone:exchangeclone_guidebook", {
    description = "Exchange Guidebook",
    inventory_image = "exchangeclone_guidebook.png",
    wield_image = "exchangeclone_guidebook.png",
    on_place = function(itemstack, player, pointed_thing) exchangeclone.show_guidebook(player) end,
    on_secondary_use = function(itemstack, player, pointed_thing) exchangeclone.show_guidebook(player) end,
})

minetest.register_chatcommand("exchangeclone_guidebook", function(name, param) exchangeclone.show_guidebook(minetest.get_player_by_name(name)) end)

minetest.register_craft{
    output = "exchangeclone:exchangeclone_guidebook",
    recipe = "exchangeclone:philosophers_stone",
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
}