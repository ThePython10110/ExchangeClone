local S = minetest.get_translator()

exchangeclone.fuels = { -- If this one didn't end in "coal," I could get rid of "fuel" on all the rest... :(
    "Alchemical Coal",
    "Mobius Fuel",
    "Aeternalis Fuel",
    "Magenta Fuel",
    "Pink Fuel",
    "Purple Fuel",
    "Violet Fuel",
    "Blue Fuel",
    "Cyan Fuel",
    "Green Fuel",
    "Lime Fuel",
    "Yellow Fuel",
    "Orange Fuel",
    "White Fuel",
}

local fuel_time = 320

for i, fuel in ipairs(exchangeclone.fuels) do
    local codified = fuel:lower():gsub(" ", "_")

    minetest.register_craftitem("exchangeclone:"..codified, {
        description = S(fuel),
        inventory_image = "exchangeclone_"..codified..".png",
        groups = {craftitem = 1, exchangeclone_fuel = 1},
    })

    minetest.register_node("exchangeclone:"..codified.."_block", {
        description = S(fuel.." Block"),
        tiles = {"exchangeclone_"..codified.."_block.png"},
        is_ground_content = false,
        sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
        groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = exchangeclone.mtg and 2 or 0},
        _mcl_blast_resistance = 8,
        _mcl_hardness = 7,
    })

    minetest.register_craft({
        type = "fuel",
        recipe = "exchangeclone:"..codified,
        burntime = fuel_time,
    })

    minetest.register_craft({
        type = "fuel",
        recipe = "exchangeclone:"..codified.."_block",
        burntime = math.min(fuel_time * 10, exchangeclone.fuel_limit)
    })
    fuel_time = math.min(fuel_time * 4, exchangeclone.fuel_limit)

    minetest.register_craft({
        output = "exchangeclone:"..codified.."_block",
        recipe = {
            {"exchangeclone:"..codified,"exchangeclone:"..codified,"exchangeclone:"..codified},
            {"exchangeclone:"..codified,"exchangeclone:"..codified,"exchangeclone:"..codified},
            {"exchangeclone:"..codified,"exchangeclone:"..codified,"exchangeclone:"..codified}
        }
    })

    minetest.register_craft({
        output = "exchangeclone:"..codified.." 9",
        recipe = {{"exchangeclone:"..codified.."_block"}}
    })

    local phil = "exchangeclone:philosophers_stone"
    local previous = (exchangeclone.fuels[i-1] and ("exchangeclone:"..exchangeclone.fuels[i-1]:lower():gsub(" ", "_"))) or exchangeclone.itemstrings.coal

    minetest.register_craft({
        output = "exchangeclone:"..codified,
        type = "shapeless",
        recipe = {
            phil,
            previous,
            previous,
            previous,
            previous,
        },
        replacements = {{phil, phil}}
    })

    minetest.register_craft({
        output = previous.." 4",
        type = "shapeless",
        recipe = {
            phil,
            "exchangeclone:"..codified,
        },
        replacements = {{phil, phil}}
    })
end