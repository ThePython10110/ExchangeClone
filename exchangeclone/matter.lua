local S = minetest.get_translator()

exchangeclone.matter_types = {
    "Red",
    "Magenta",
    "Pink",
    "Purple",
    "Violet",
    "Blue",
    "Cyan",
    "Green",
    "Lime",
    "Yellow",
    "Orange",
    "White",
}

minetest.register_craftitem("exchangeclone:dark_matter", {
    description = S("Dark Matter Orb"),
    wield_image = "exchangeclone_dark_matter.png",
    inventory_image = "exchangeclone_dark_matter.png",
    groups = {craftitem = 1}
})

minetest.register_craft({
    output = "exchangeclone:dark_matter 4",
    recipe = {
        {"exchangeclone:dark_matter_block"}
    }
})

minetest.register_node("exchangeclone:dark_matter_block", {
    description = S("Dark Matter Block"),
    tiles = {"exchangeclone_dark_matter_block.png"},
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = exchangeclone.mtg and 4 or 0},
	_mcl_blast_resistance = 1500,
	_mcl_hardness = 12,
})

minetest.register_craft({
    output = "exchangeclone:dark_matter",
    recipe = {
        {"exchangeclone:aeternalis_fuel", "exchangeclone:aeternalis_fuel", "exchangeclone:aeternalis_fuel"},
        {"exchangeclone:aeternalis_fuel", exchangeclone.mcl and "mcl_core:diamondblock" or 'default:diamondblock', "exchangeclone:aeternalis_fuel"},
        {"exchangeclone:aeternalis_fuel", "exchangeclone:aeternalis_fuel", "exchangeclone:aeternalis_fuel"}
    }
})

minetest.register_craft({
    output = "exchangeclone:dark_matter_block",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter"},
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter"}
    }
})

for i, matter in ipairs(exchangeclone.matter_types) do
    local codified = matter:lower().."_matter"
    local itemstring = "exchangeclone:"..codified

    minetest.register_craftitem(itemstring, {
        description = S(matter.." Matter Orb"),
        wield_image = "exchangeclone_"..codified..".png",
        inventory_image = "exchangeclone_"..codified..".png",
        groups = {craftitem = 1},
    })

    minetest.register_node(itemstring.."_block", {
        description = S(matter.." Matter Block"),
        tiles = {"exchangeclone_"..codified.."_block.png"},
        is_ground_content = false,
        light_source = 14,
        sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
        groups = {pickaxey=6, material_stone=1, cracky = 3, building_block = 1, level = exchangeclone.mtg and 5 or 0},
        _mcl_blast_resistance = 1500,
        _mcl_hardness = 37,
    })

    local previous = exchangeclone.matter_types[i-1] or "Dark"
    previous = "exchangeclone:"..previous:lower().."_matter"
    local fuel = "exchangeclone:"..exchangeclone.fuels[i+2]:lower():gsub(" ", "_")

    minetest.register_craft({
        output = itemstring,
        recipe = {
            {fuel, fuel, fuel},
            {previous, previous, previous},
            {fuel, fuel, fuel},
        }
    })

    minetest.register_craft({
        output = itemstring.."_block",
        recipe = {
            {itemstring, itemstring},
            {itemstring, itemstring}
        }
    })

    minetest.register_craft({
        output = itemstring.." 4",
        recipe = {
            {itemstring.."_block",}
        }
    })
end