local S = minetest.get_translator()

local charcoal_itemstring = exchangeclone.mcl and "mcl_core:charcoal_lump" or "group:tree"

minetest.register_craftitem("exchangeclone:low_covalence_dust", {
    description = S("Low Covalence Dust"),
    inventory_image = "exchangeclone_dust.png^[colorize:#00ff00:128",
    wield_image = "exchangeclone_dust.png^[colorize:#00ff00:128",
})
minetest.register_craftitem("exchangeclone:medium_covalence_dust", {
    description = S("Medium Covalence Dust"),
    inventory_image = "exchangeclone_dust.png^[colorize:#00ffff:128",
    wield_image = "exchangeclone_dust.png^[colorize:#00ffff:128",
})

minetest.register_craftitem("exchangeclone:high_covalence_dust", {
    description = S("High Covalence Dust"),
    inventory_image = "exchangeclone_dust.png^[colorize:#0000ff:128",
    wield_image = "exchangeclone_dust.png^[colorize:#0000ff:128",
})

minetest.register_craft({
    output = "exchangeclone:low_covalence_dust 40",
    type = "shapeless",
    recipe = {
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        charcoal_itemstring,
    }
})

minetest.register_craft({
    output = "exchangeclone:medium_covalence_dust 40",
    type = "shapeless",
    recipe = {
        exchangeclone.itemstrings.iron, exchangeclone.itemstrings.redstoneworth
    }
})

minetest.register_craft({
    output = "exchangeclone:high_covalence_dust 40",
    type = "shapeless",
    recipe = {
        exchangeclone.itemstrings.diamond, exchangeclone.itemstrings.coal
    }
})