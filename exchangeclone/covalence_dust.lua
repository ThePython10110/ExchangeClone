local cobble_itemstring = exchangeclone.mcl and "mcl_core:cobble" or "default:cobble"
local charcoal_itemstring = exchangeclone.mcl and "mcl_core:charcoal" or "group:tree"
local iron_itemstring = exchangeclone.mcl and "mcl_core:iron_ingot" or "default:steel_ingot"
local redstone_itemstring = exchangeclone.mcl and "mcl_core:redstone" or "default:obsidian"
local diamond_itemstring = exchangeclone.mcl and "mcl_core:diamond" or "default:diamond"
local coal_itemstring = exchangeclone.mcl and "mcl_core:coal_lump" or "default:coal_lump"

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
        cobble_itemstring,
        cobble_itemstring,
        cobble_itemstring,
        cobble_itemstring,
        cobble_itemstring,
        cobble_itemstring,
        cobble_itemstring,
        cobble_itemstring,
        charcoal_itemstring,
    }
})

minetest.register_craft({
    output = "exchangeclone:medium_covalence_dust 40",
    type = "shapeless",
    recipe = {
        iron_itemstring, redstone_itemstring
    }
})

minetest.register_craft({
    output = "exchangeclone:high_covalence_dust 40",
    type = "shapeless",
    recipe = {
        diamond_itemstring, coal_itemstring
    }
})