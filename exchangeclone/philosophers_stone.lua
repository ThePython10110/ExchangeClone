local S = minetest.get_translator()

local phil = "exchangeclone:philosophers_stone"

local function show_enchanting(player)
    local player_meta = player:get_meta()
    player_meta:set_int("mcl_enchanting:num_bookshelves", 8) -- 15 for max enchantments
    player_meta:set_string("mcl_enchanting:table_name", S("Enchanting Table").." (".. S("Philosopher's Stone")..")")
    mcl_enchanting.show_enchanting_formspec(player)
end

local width = (exchangeclone.mcl and 9) or 8

local repairing_formspec =
    "size["..tostring(width)..", 7]"..
    "label[0.5,0.5;Repairing]"..
    "label["..tostring(width/3-0.5)..",0.5;Dust]"..
    "list[current_player;exchangeclone_covalence_dust;"..tostring(width/3-0.5)..",1;1,1]"..
    "label["..tostring(width/2-0.5)..",0.5;Gear]"..
    "list[current_player;exchangeclone_covalence_gear;"..tostring(width/2-0.5)..",1;1,1]"..
    "label["..tostring(2*width/3-0.5)..",0.5;Output]"..
    "list[current_player;exchangeclone_covalence_output;"..tostring(2*width/3-0.5)..",1;1,1]"..
    exchangeclone.inventory_formspec(0,2.75)..
    "listring[current_player;main]"..
    "listring[current_player;exchangeclone_covalence_gear]"..
    "listring[current_player;main]"..
    "listring[current_player;exchangeclone_covalence_dust]"..
    "listring[current_player;main]"..
    "listring[current_player;exchangeclone_covalence_output]"..
    "listring[current_player;main]"

if exchangeclone.mcl then
    repairing_formspec = repairing_formspec..
        mcl_formspec.get_itemslot_bg(width/3-0.5,1,1,1)..
        mcl_formspec.get_itemslot_bg(width/2-0.5,1,1,1)..
        mcl_formspec.get_itemslot_bg(2*width/3-0.5,1,1,1)
end

-- exchangeclone.node_transmutations moved to zzzz_exchangeclone_init so it would load first
-- This means it can be modified by other mods

function exchangeclone.phil_action(itemstack, player, center)
    if exchangeclone.check_cooldown(player, "phil") then return end
    local mode = player:get_player_control().sneak and 2 or 1
    local start_node = minetest.get_node(center)
    local transmute_name = exchangeclone.node_transmutations[mode][start_node.name]
    if not transmute_name and mode == 2 then
        transmute_name = exchangeclone.node_transmutations[1][start_node.name]
    end
    if not transmute_name then return end
	local charge = math.max(itemstack:get_meta():get_int("exchangeclone_tool_charge"), 1)
    local nodes
    if charge == 1 then
        nodes = {center}
    else
        local vector1, vector2 = exchangeclone.process_range(player, "basic_radius", charge)
        if not (vector1 and vector2) then return end
        local pos1, pos2 = vector.add(center, vector1), vector.add(center, vector2)
        nodes = minetest.find_nodes_in_area(pos1, pos2, start_node.name)
    end
    exchangeclone.play_sound(player, "exchangeclone_transmute")
    for i, pos in pairs(nodes) do
        if minetest.is_protected(pos, player:get_player_name()) then
            minetest.record_protection_violation(pos, player:get_player_name())
        else
            local node = minetest.get_node(pos)
            node.name = transmute_name
            minetest.swap_node(pos, node)
        end
    end
    exchangeclone.start_cooldown(player, "phil", 0.3)
end

local on_left_click
if exchangeclone.mcl then
    on_left_click = function(itemstack, player, pointed_thing)
        if player:get_player_control().sneak then
            show_enchanting(player)
        else
            if player:get_player_control().aux1 then
                minetest.show_formspec(player:get_player_name(), "exchangeclone_repairing", repairing_formspec)
            else
                mcl_crafting_table.show_crafting_form(player)
            end
        end
    end
else
    on_left_click = function(itemstack, player, pointed_thing)
        minetest.show_formspec(player:get_player_name(), "exchangeclone_repairing", repairing_formspec)
    end
end

local function on_right_click(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end
    if player:get_player_control().aux1 then
        return exchangeclone.charge_update(itemstack, player)
    end
    if pointed_thing and pointed_thing.type == "node" then
        exchangeclone.phil_action(itemstack, player, pointed_thing.under)
    end
end

minetest.register_tool("exchangeclone:philosophers_stone", {
    description = S("Philosopher's Stone").."\n"..S("Always returned when crafting"),
    inventory_image = "exchangeclone_philosophers_stone.png",
    wield_image = "exchangeclone_philosophers_stone.png",
    exchangeclone_tool_charge = 0,
    on_use = on_left_click,
    on_place = on_right_click,
    on_secondary_use = on_right_click,
    groups = {philosophers_stone = 1, disable_repair = 1, fire_immune = 1}
})

exchangeclone.set_charge_type("exchangeclone:philosophers_stone", "phil")

local diamond = exchangeclone.itemstrings.diamond
local corner = exchangeclone.itemstrings.glowstoneworth
local side = exchangeclone.itemstrings.redstoneworth

minetest.register_craft({
    output = "exchangeclone:philosophers_stone",
    recipe = {
        {corner, side, corner},
        {side, diamond, side},
        {corner, side, corner}
    }
})

minetest.register_craft({
    output = "mcl_core:coal_lump",
    type = "shapeless",
    recipe = {
        phil,
        "mcl_core:charcoal_lump",
        "mcl_core:charcoal_lump",
        "mcl_core:charcoal_lump",
        "mcl_core:charcoal_lump"
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "mcl_core:charcoal_lump 4",
    type = "shapeless",
    recipe = {
        phil,
        "mcl_core:coal_lump"
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.iron,
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.coal,
        exchangeclone.itemstrings.coal,
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.coal.." 2",
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.iron
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.copper.." 2",
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.iron,
        exchangeclone.itemstrings.iron,
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.iron.." 2",
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.copper,
        exchangeclone.itemstrings.copper,
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "mcl_throwing:ender_pearl",
    type = "shapeless",
    recipe = {
        phil,
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "default:tin_ingot 4",
    type = "shapeless",
    recipe = {
        phil,
        "default:copper_ingot",
        "default:copper_ingot",
        "default:copper_ingot",
        "default:copper_ingot",
        "default:copper_ingot",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "default:copper_ingot 5",
    type = "shapeless",
    recipe = {
        phil,
        "default:tin_ingot",
        "default:tin_ingot",
        "default:tin_ingot",
        "default:tin_ingot",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.iron.." 8",
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.gold
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.gold,
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.iron,
        exchangeclone.itemstrings.iron,
        exchangeclone.itemstrings.iron,
        exchangeclone.itemstrings.iron,
        exchangeclone.itemstrings.iron,
        exchangeclone.itemstrings.iron,
        exchangeclone.itemstrings.iron,
        exchangeclone.itemstrings.iron,
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.emeraldworth,
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.gold,
        exchangeclone.itemstrings.gold,
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.gold.." 2",
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.emeraldworth,
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.diamond,
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.emeraldworth,
        exchangeclone.itemstrings.emeraldworth,
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.emeraldworth.." 2",
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.diamond
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "mcl_nether:glowstone_dust",
    type = "shapeless",
    recipe = {
        phil,
        "mesecons:redstone",
        "mesecons:redstone",
        "mesecons:redstone",
        "mesecons:redstone",
        "mesecons:redstone",
        "mesecons:redstone",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "mesecons:redstone 6",
    type = "shapeless",
    recipe = {
        phil,
        "mcl_nether:glowstone_dust",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "mcl_core:lapis",
    type = "shapeless",
    recipe = {
        phil,
        "mcl_nether:glowstone_dust",
        "mcl_nether:glowstone_dust"
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "mcl_nether:glowstone_dust 2",
    type = "shapeless",
    recipe = {
        phil,
        "mcl_core:lapis",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "exchangeclone:alchemical_coal",
    type = "shapeless",
    recipe = {
        phil,
        exchangeclone.itemstrings.coal,
        exchangeclone.itemstrings.coal,
        exchangeclone.itemstrings.coal,
        exchangeclone.itemstrings.coal,
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = exchangeclone.itemstrings.coal.." 4",
    type = "shapeless",
    recipe = {
        phil,
        "exchangeclone:alchemical_coal",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "exchangeclone:mobius_fuel",
    type = "shapeless",
    recipe = {
        phil,
        "exchangeclone:alchemical_coal",
        "exchangeclone:alchemical_coal",
        "exchangeclone:alchemical_coal",
        "exchangeclone:alchemical_coal",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "exchangeclone:alchemical_coal 4",
    type = "shapeless",
    recipe = {
        phil,
        "exchangeclone:mobius_fuel",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "exchangeclone:aeternalis_fuel",
    type = "shapeless",
    recipe = {
        phil,
        "exchangeclone:mobius_fuel",
        "exchangeclone:mobius_fuel",
        "exchangeclone:mobius_fuel",
        "exchangeclone:mobius_fuel",
    },
    replacements = {{phil, phil}}
})

minetest.register_craft({
    output = "exchangeclone:mobius_fuel 4",
    type = "shapeless",
    recipe = {
        phil,
        "exchangeclone:aeternalis_fuel",
    },
    replacements = {{phil, phil}}
})