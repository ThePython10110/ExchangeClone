local S = core.get_translator()

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

core.register_craftitem("ec_matter:dark_matter", {
    description = S("Dark Matter Orb"),
    wield_image = "exchangeclone_dark_matter.png",
    inventory_image = "exchangeclone_dark_matter.png",
    groups = {craftitem = 1}
})

core.register_craft({
    output = "ec_matter:dark_matter 4",
    recipe = {
        {"ec_matter:dark_matter_block"}
    }
})

core.register_node("ec_matter:dark_matter_block", {
    description = S("Dark Matter Block"),
    tiles = {"exchangeclone_dark_matter_block.png"},
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = exchangeclone.mtg and 4 or 0},
	_mcl_blast_resistance = 1500,
	_mcl_hardness = 12,
})

core.register_craft({
    output = "ec_matter:dark_matter",
    recipe = {
        {"ec_fuel:aeternalis_fuel", "ec_fuel:aeternalis_fuel", "ec_fuel:aeternalis_fuel"},
        {"ec_fuel:aeternalis_fuel", exchangeclone.mcl and "mcl_core:diamondblock" or 'default:diamondblock', "ec_fuel:aeternalis_fuel"},
        {"ec_fuel:aeternalis_fuel", "ec_fuel:aeternalis_fuel", "ec_fuel:aeternalis_fuel"}
    }
})

core.register_craft({
    output = "ec_matter:dark_matter_block",
    recipe = {
        {"ec_matter:dark_matter", "ec_matter:dark_matter"},
        {"ec_matter:dark_matter", "ec_matter:dark_matter"}
    }
})

for i, matter in ipairs(exchangeclone.matter_types) do
    local codified = matter:lower().."_matter"
    local itemstring = "ec_matter:"..codified

    core.register_craftitem(itemstring, {
        description = S(matter.." Matter Orb"),
        wield_image = "exchangeclone_"..codified..".png",
        inventory_image = "exchangeclone_"..codified..".png",
        groups = {craftitem = 1},
    })

    core.register_node(itemstring.."_block", {
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
    previous = "ec_matter:"..previous:lower().."_matter"
    local fuel
    if matter ~= "Red" then
        fuel = "ec_fuel:"..exchangeclone.fuels[i+1].name:lower():gsub(" ", "_")
    else
        fuel = "ec_fuel:aeternalis_fuel"
    end

    core.register_craft({
        output = itemstring,
        recipe = {
            {fuel, fuel, fuel},
            {previous, previous, previous},
            {fuel, fuel, fuel},
        }
    })

    core.register_craft({
        output = itemstring.."_block",
        recipe = {
            {itemstring, itemstring},
            {itemstring, itemstring}
        }
    })

    core.register_craft({
        output = itemstring.." 4",
        recipe = {
            {itemstring.."_block",}
        }
    })
    
    core.register_alias("exchangeclone:"..codified, itemstring)
    core.register_alias("exchangeclone:"..codified.."_block", itemstring.."_block")
end