local S = core.get_translator()
exchangeclone.fuels = {
    {
        name = "Alchemical Coal",
        color = exchangeclone.colors.red.hex,
        no_symbol = true,
        burn_time = 80*4,
        source = exchangeclone.itemstrings.coal
    },
    {
        name = "Mobius Fuel",
        color = exchangeclone.colors.red.hex,
        burn_time = 80*4^2,
        source = "ec_fuel:alchemical_coal"
    },
    {
        name = "Aeternalis Fuel",
        color = "#eeeebb",
        burn_time = 80*4^3,
        source = "ec_fuel:mobius_fuel"
    },
    {
        name = "Magenta Fuel",
        color = exchangeclone.colors.magenta.hex,
        burn_time = 80*4^4,
        source = "ec_fuel:aeternalis_fuel"
    },
    {
        name = "Pink Fuel",
        color = exchangeclone.colors.pink.hex,
        burn_time = 80*4^5,
        source = "ec_fuel:magenta_fuel"
    },
    {
        name = "Purple Fuel",
        color = exchangeclone.colors.purple.hex,
        burn_time = 80*4^6,
        source = "ec_fuel:pink_fuel"
    },
    {
        name = "Violet Fuel",
        color = "#4821b0",
        burn_time = 80*4^7,
        source = "ec_fuel:purple_fuel"
    },
    {
        name = "Blue Fuel",
        color = exchangeclone.colors.blue.hex,
        burn_time = 80*4^8,
        source = "ec_fuel:violet_fuel"
    },
    {
        name = "Cyan Fuel",
        color = exchangeclone.colors.cyan.hex,
        burn_time = 80*4^9,
        source = "ec_fuel:blue_fuel"
    },
    {
        name = "Green Fuel",
        color = exchangeclone.colors.green.hex,
        burn_time = 80*4^10,
        source = "ec_fuel:cyan_fuel"
    },
    {
        name = "Lime Fuel",
        color = exchangeclone.colors.lime.hex,
        burn_time = 80*4^11,
        source = "ec_fuel:green_fuel"
    },
    {
        name = "Yellow Fuel",
        color = exchangeclone.colors.yellow.hex,
        burn_time = 80*4^12,
        source = "ec_fuel:lime_fuel"
    },
    {
        name = "Orange Fuel",
        color = exchangeclone.colors.orange.hex,
        burn_time = 80*4^13,
        source = "ec_fuel:yellow_fuel"
    },
    {
        name = "White Fuel",
        color = exchangeclone.colors.white.hex,
        burn_time = 80*4^14,
        source = "ec_fuel:orange_fuel"
    },
}

local phil = "ec_phil:philosophers_stone"

function exchangeclone.register_fuel(fuel_data)
    local item_texture = "exchangeclone_fuel.png"
    local node_texture = "exchangeclone_fuel_block.png"
    if fuel_data.color then
        item_texture = item_texture.."^[multiply:"..fuel_data.color
        node_texture = node_texture.."^[multiply:"..fuel_data.color
    end
    if not fuel_data.no_symbol then
        item_texture = item_texture.."^exchangeclone_fuel_symbol.png"
        node_texture = node_texture.."^exchangeclone_fuel_symbol.png"
    end
    item_texture = item_texture.."^exchangeclone_fuel_border.png"

    local name_but_with_underscores___ = fuel_data.name:lower():gsub(" ", "_")
    local item_itemstring = "ec_fuel:"..name_but_with_underscores___
    local node_itemstring = "ec_fuel:"..name_but_with_underscores___.."_block"

    core.register_craftitem(item_itemstring, {
        description = S(fuel_data.name),
        inventory_image = item_texture,
        groups = {craftitem = 1, exchangeclone_fuel = 1},
    })

    core.register_node(node_itemstring, {
        description = S(fuel_data.name.." Block"),
        tiles = {node_texture},
        is_ground_content = false,
        sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
        groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = exchangeclone.mtg and 2 or 0},
        _mcl_blast_resistance = 8,
        _mcl_hardness = 7,
    })

    core.register_craft({
        type = "fuel",
        recipe = item_itemstring,
        burntime = fuel_data.burn_time,
    })

    core.register_craft({
        type = "fuel",
        recipe = node_itemstring,
        burntime = math.min(fuel_data.burn_time * 10, exchangeclone.fuel_limit)
    })

    core.register_craft({
        output = node_itemstring,
        recipe = {
            {item_itemstring,item_itemstring,item_itemstring},
            {item_itemstring,item_itemstring,item_itemstring},
            {item_itemstring,item_itemstring,item_itemstring},
        }
    })

    core.register_craft({
        output = item_itemstring.." 9",
        recipe = {{node_itemstring}}
    })

    core.register_craft({
        output = item_itemstring,
        type = "shapeless",
        recipe = {
            phil,
            fuel_data.source,
            fuel_data.source,
            fuel_data.source,
            fuel_data.source,
        },
        replacements = {{phil, phil}}
    })

    core.register_craft({
        output = fuel_data.source.." 4",
        type = "shapeless",
        recipe = {
            phil,
            item_itemstring,
        },
        replacements = {{phil, phil}}
    })
end

for i, fuel in pairs(exchangeclone.fuels) do
    exchangeclone.register_fuel(fuel)
end

core.register_alias("exchangeclone:alchemical_coal", "ec_fuel:alchemical_coal")
core.register_alias("exchangeclone:mobius_fuel", "ec_fuel:mobius_fuel")
core.register_alias("exchangeclone:aeternalis_fuel", "ec_fuel:aeternalis_fuel")