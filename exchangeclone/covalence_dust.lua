local charcoal_itemstring = exchangeclone.mcl and "mcl_core:charcoal" or "group:tree"
local redstone_itemstring = exchangeclone.mcl and "mcl_core:redstone" or "default:obsidian"

minetest.register_craftitem("exchangeclone:low_covalence_dust", {
    description = "Low Covalence Dust"
})

minetest.register_craftitem("exchangeclone:medium_covalence_dust", {
    description = "Medium Covalence Dust"
})

minetest.register_craftitem("exchangeclone:high_covalence_dust", {
    description = "High Covalence Dust"
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
        exchangeclone.itemstrings.iron, redstone_itemstring
    }
})

minetest.register_craft({
    output = "exchangeclone:high_covalence_dust 40",
    type = "shapeless",
    recipe = {
        exchangeclone.itemstrings.diamond, exchangeclone.itemstrings.coal
    }
})