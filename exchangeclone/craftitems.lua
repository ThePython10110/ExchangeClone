local S = minetest.get_translator()

local function get_level(level)
    if exchangeclone.mcl then
        return nil
    else
        return level
    end
end

minetest.register_craftitem("exchangeclone:alchemical_coal", {
    description = S("Alchemical Coal"),
    wield_image = "exchangeclone_alchemical_coal.png",
    inventory_image = "exchangeclone_alchemical_coal.png",
	groups = { craftitem=1},
})

minetest.register_craftitem("exchangeclone:mobius_fuel", {
    description = S("Mobius Fuel"),
    wield_image = "exchangeclone_mobius_fuel.png",
    inventory_image = "exchangeclone_mobius_fuel.png",
	groups = { craftitem=1},
})

minetest.register_craftitem("exchangeclone:aeternalis_fuel", {
    description = S("Aeternalis Fuel"),
    wield_image = "exchangeclone_aeternalis_fuel.png",
    inventory_image = "exchangeclone_aeternalis_fuel.png",
	groups = { craftitem=1},
})

minetest.register_node("exchangeclone:alchemical_coal_block", {
    description = S("Alchemical Coal Block"),
    tiles = {"exchangeclone_alchemical_coal_block.png"},
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = get_level(2)}, --ridiculous workaround
	_mcl_blast_resistance = 8,
	_mcl_hardness = 7,
})

minetest.register_node("exchangeclone:mobius_fuel_block", {
    description = S("Mobius Fuel Block"),
    tiles = {"exchangeclone_mobius_fuel_block.png"},
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = get_level(2)}, --ridiculous workaround
	_mcl_blast_resistance = 10,
	_mcl_hardness = 8,
})

minetest.register_node("exchangeclone:aeternalis_fuel_block", {
    description = S("Aeternalis Fuel Block"),
    tiles = {"exchangeclone_aeternalis_fuel_block.png"},
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = get_level(2)}, --ridiculous workaround
	_mcl_blast_resistance = 10,
	_mcl_hardness = 8,
})

minetest.register_craft({
    type = "fuel",
    recipe = "exchangeclone:alchemical_coal",
    burntime = 320,
})

minetest.register_craft({
    type = "fuel",
    recipe = "exchangeclone:mobius_fuel",
    burntime = 1280,
})

minetest.register_craft({
    type = "fuel",
    recipe = "exchangeclone:aeternalis_fuel",
    burntime = 5120,
})

minetest.register_craft({
    type = "fuel",
    recipe = "exchangeclone:alchemical_coal_block",
    burntime = 3200,
})

minetest.register_craft({
    type = "fuel",
    recipe = "exchangeclone:mobius_fuel_block",
    burntime = 12800,
})

minetest.register_craft({
    type = "fuel",
    recipe = "exchangeclone:aeternalis_fuel_block",
    burntime = 51200,
})

minetest.register_craft({
    output = "exchangeclone:alchemical_coal_block",
    recipe = {
        {"exchangeclone:alchemical_coal","exchangeclone:alchemical_coal","exchangeclone:alchemical_coal"},
        {"exchangeclone:alchemical_coal","exchangeclone:alchemical_coal","exchangeclone:alchemical_coal"},
        {"exchangeclone:alchemical_coal","exchangeclone:alchemical_coal","exchangeclone:alchemical_coal"}
    }
})

minetest.register_craft({
    output = "exchangeclone:alchemical_coal 9",
    recipe = {{"exchangeclone:alchemical_coal_block"}}
})

minetest.register_craft({
    output = "exchangeclone:aeternalis_fuel_block",
    recipe = {
        {"exchangeclone:aeternalis_fuel","exchangeclone:aeternalis_fuel","exchangeclone:aeternalis_fuel"},
        {"exchangeclone:aeternalis_fuel","exchangeclone:aeternalis_fuel","exchangeclone:aeternalis_fuel"},
        {"exchangeclone:aeternalis_fuel","exchangeclone:aeternalis_fuel","exchangeclone:aeternalis_fuel"}
    }
})

minetest.register_craft({
    output = "exchangeclone:aeternalis_fuel 9",
    recipe = {{"exchangeclone:aeternalis_fuel_block"}}
})

minetest.register_craft({
    output = "exchangeclone:mobius_fuel_block",
    recipe = {
        {"exchangeclone:mobius_fuel","exchangeclone:mobius_fuel","exchangeclone:mobius_fuel"},
        {"exchangeclone:mobius_fuel","exchangeclone:mobius_fuel","exchangeclone:mobius_fuel"},
        {"exchangeclone:mobius_fuel","exchangeclone:mobius_fuel","exchangeclone:mobius_fuel"}
    }
})

minetest.register_craft({
    output = "exchangeclone:mobius_fuel 9",
    recipe = {{"exchangeclone:mobius_fuel_block"}}
})

minetest.register_craftitem("exchangeclone:dark_matter", {
    description = S("Dark Matter Orb"),
    wield_image = "exchangeclone_dark_matter.png",
    inventory_image = "exchangeclone_dark_matter.png",
    groups = {craftitem = 1}
})

minetest.register_craftitem("exchangeclone:red_matter", {
    description = S("Red Matter Orb"),
    wield_image = "exchangeclone_red_matter.png",
    inventory_image = "exchangeclone_red_matter.png",
    groups = {craftitem = 1},
})

minetest.register_node("exchangeclone:dark_matter_block", {
    description = S("Dark Matter Block"),
    tiles = {"exchangeclone_dark_matter_block.png"},
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = get_level(4)}, --ridiculous workaround
	_mcl_blast_resistance = 1500,
	_mcl_hardness = 12,
})

minetest.register_node("exchangeclone:red_matter_block", {
    description = S("Red Matter Block"),
    tiles = {"exchangeclone_red_matter_block.png"},
	is_ground_content = false,
	light_source = 14,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	groups = {pickaxey=6, material_stone=1, cracky = 3, building_block = 1, level = get_level(5)},
	_mcl_blast_resistance = 1500,
	_mcl_hardness = 37,
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
    output = "exchangeclone:red_matter",
    recipe = {
        {"exchangeclone:aeternalis_fuel", "exchangeclone:aeternalis_fuel", "exchangeclone:aeternalis_fuel"},
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", "exchangeclone:dark_matter"},
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

minetest.register_craft({
    output = "exchangeclone:red_matter_block",
    recipe = {
        {"exchangeclone:red_matter", "exchangeclone:red_matter"},
        {"exchangeclone:red_matter", "exchangeclone:red_matter"}
    }
})

minetest.register_craft({
    output = "exchangeclone:dark_matter 4",
    recipe = {
        {"exchangeclone:dark_matter_block"}
    }
})

minetest.register_craft({
    output = "exchangeclone:red_matter 4",
    recipe = {
        {"exchangeclone:red_matter_block",}
    }
})