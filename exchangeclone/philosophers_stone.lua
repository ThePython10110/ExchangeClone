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

exchangeclone.node_transmutations = {
    { --use
        ["mcl_core:stone"] = "mcl_core:cobble",
        ["mcl_core:cobble"] = "mcl_core:stone",
        ["mcl_core:dirt_with_grass"] = "mcl_core:sand",
        ["mcl_core:dirt"] = "mcl_core:sand",
        ["mcl_core:sand"] = "mcl_core:dirt_with_grass",
        ["mcl_core:podzol"] = "mcl_core:redsand",
        ["mcl_core:redsand"] = "mcl_core:podzol",
        ["mcl_flowers:tallgrass"] = "mcl_flowers:fern",
        ["mcl_flowers:fern"] = "mcl_flowers:tallgrass",
        ["mcl_core:redsandstone"] = "mcl_core:gravel",
        ["mcl_farming:pumpkin"] = "mcl_farming:melon",
        ["mcl_farming:melon"] = "mcl_farming:pumpkin",
        ["mcl_core:water_source"] = "mcl_core:ice",
        ["mclx_core:river_water_source"] = "mcl_core:ice",
        ["mcl_core:ice"] = "mcl_core:water_source",
        ["mcl_core:lava_source"] = "mcl_core:obsidian",
        ["mcl_core:obsidian"] = "mcl_core:lava_source",
        ["mcl_flowers:dandelion"] = "mcl_flowers:poppy",
        ["mcl_flowers:poppy"] = "mcl_flowers:dandelion",
        ["mcl_mushrooms:mushroom_brown"] = "mcl_mushrooms:mushroom_red",
        ["mcl_mushrooms:mushroom_red"] = "mcl_mushrooms:mushroom_brown",
        ["mcl_core:acacialeaves"] = "mcl_core:birchleaves",
        ["mcl_core:birchleaves"] = "mcl_core:darkleaves",
        ["mcl_core:darkleaves"] = "mcl_core:jungleleaves",
        ["mcl_core:jungleleaves"] = "mcl_mangrove:mangroveleaves",
        ["mcl_mangrove:mangroveleaves"] = "mcl_core:leaves",
        ["mcl_core:leaves"] = "mcl_core:spruceleaves",
        ["mcl_core:spruceleaves"] = "mcl_core:acacialeaves",
        ["mcl_core:acaciatree"] = "mcl_core:birchtree",
        ["mcl_core:birchtree"] = "mcl_core:darktree",
        ["mcl_core:darktree"] = "mcl_core:jungletree",
        ["mcl_core:jungletree"] = "mcl_mangrove:mangrove_tree",
        ["mcl_mangrove:mangrove_tree"] = "mcl_core:tree",
        ["mcl_core:tree"] = "mcl_core:sprucetree",
        ["mcl_core:sprucetree"] = "mcl_core:acaciatree",
        ["mcl_crimson:warped_fungus"] = "mcl_crimson:crimson_fungus",
        ["mcl_crimson:warped_hyphae"] = "mcl_crimson:crimson_hyphae",
        ["mcl_crimson:warped_nylium"] = "mcl_crimson:crimson_nylium",
        ["mcl_crimson:warped_roots"] = "mcl_crimson:crimson_roots",
        ["mcl_crimson:warped_wart_block"] = "mcl_nether:nether_wart_block",
        ["mcl_crimson:crimson_fungus"] = "mcl_crimson:warped_fungus",
        ["mcl_crimson:crimson_hyphae"] = "mcl_crimson:warped_hyphae",
        ["mcl_crimson:crimson_nylium"] = "mcl_crimson:warped_nylium",
        ["mcl_crimson:crimson_roots"] = "mcl_crimson:warped_roots",
        ["mcl_nether:nether_wart_block"] = "mcl_crimson:warped_wart_block",
        ["mcl_core:glass"] = "mcl_core:sand",
        ["mcl_blackstone:blackstone"] = "mcl_blackstone:basalt",
        ["mcl_blackstone:basalt"] = "mcl_blackstone:blackstone",
        ["mcl_flowers:double_grass"] = "mcl_flowers:fern",
        --["mcl_flowers:double_grass_top"] = "air",
        ["mcl_core:andesite"] = "mcl_core:diorite",
        ["mcl_core:diorite"] = "mcl_core:granite",
        ["mcl_core:granite"] = "mcl_deepslate:tuff",
        ["mcl_deepslate:tuff"] = "mcl_core:andesite",
        ["mcl_deepslate:deepslate"] = "mcl_deepslate:deepslate_cobbled",
        ["mcl_deepslate:deepslate_cobbled"] = "mcl_deepslate:deepslate",
        ["mcl_core:stone_with_coal"] = "mcl_deepslate:deepslate_with_coal",
        ["mcl_core:stone_with_iron"] = "mcl_deepslate:deepslate_with_iron",
        ["mcl_core:stone_with_lapis"] = "mcl_deepslate:deepslate_with_lapis",
        ["mcl_core:stone_with_gold"] = "mcl_deepslate:deepslate_with_gold",
        ["mcl_core:stone_with_emerald"] = "mcl_deepslate:deepslate_with_emerald",
        ["mcl_core:stone_with_redstone"] = "mcl_deepslate:deepslate_with_redstone",
        ["mcl_core:stone_with_redstone_lit"] = "mcl_deepslate:deepslate_with_redstone_lit",
        ["mcl_core:stone_with_diamond"] = "mcl_deepslate:deepslate_with_diamond",
        ["mcl_copper:stone_with_copper"] = "mcl_deepslate:deepslate_with_copper",
        ["mcl_deepslate:deepslate_with_coal"] = "mcl_core:stone_with_coal",
        ["mcl_deepslate:deepslate_with_iron"] = "mcl_core:stone_with_iron",
        ["mcl_deepslate:deepslate_with_lapis"] = "mcl_core:stone_with_lapis",
        ["mcl_deepslate:deepslate_with_gold"] = "mcl_core:stone_with_gold",
        ["mcl_deepslate:deepslate_with_emerald"] = "mcl_core:stone_with_emerald",
        ["mcl_deepslate:deepslate_with_redstone"] = "mcl_core:stone_with_redstone",
        ["mcl_deepslate:deepslate_with_diamond"] = "mcl_core:stone_with_diamond",
        ["mcl_deepslate:deepslate_with_copper"] = "mcl_copper:stone_with_copper",
        ["mcl_end:end_stone"] = "mcl_nether:netherrack",
        ["mcl_nether:soul_sand"] = "mcl_blackstone:soul_soil",
        ["mcl_blackstone:soul_soil"] = "mcl_nether:soul_sand",

        ["default:stone"] = "default:cobble",
        ["default:desert_stone"] = "default:desert_cobble",
        ["default:cobble"] = "default:stone",
        ["default:desert_cobble"] = "default:desert_stone",
        ["default:dirt_with_grass"] = "default:sand",
        ["default:dirt_with_snow"] = "default:sand",
        ["default:dirt_with_dry_grass"] = "default:sand",
        ["default:dry_dirt_with_dry_grass"] = "default:desert_sand",
        ["default:dirt"] = "default:sand",
        ["default:dry_dirt"] = "default:desert_sand",
        ["default:dirt_with_coniferous_litter"] = "default:sand",
        ["default:dirt_with_rainforest_litter"] = "default:sand",
        ["default:sand"] = "default:dirt_with_grass",
        ["default:desert_sand"] = "default:dry_dirt_with_dry_grass",
        ["default:silver_sand"] = "default:dirt_with_grass",
        ["default:grass_1"] = "default:dry_shrub",
        ["default:grass_2"] = "default:dry_shrub",
        ["default:grass_3"] = "default:dry_shrub",
        ["default:grass_4"] = "default:dry_shrub",
        ["default:grass_5"] = "default:dry_shrub",
        ["default:gravel"] = "default:sandstone",
        ["default:sandstone"] = "default:gravel",
        ["default:desert_sandstone"] = "default:gravel",
        ["default:silver_sandstone"] = "default:gravel",
        ["default:water_source"] = "default:ice",
        ["default:river_water_source"] = "default:ice",
        ["default:ice"] = "default:water_source",
        ["default:lava_source"] = "default:obsidian",
        ["default:obsidian"] = "default:lava_source",
        ["flowers:mushroom_brown"] = "flowers:mushroom_red",
        ["flowers:mushroom_red"] = "flowers:mushroom_brown",
        ["flowers:dandelion_yellow"] = "flowers:rose",
        ["flowers:rose"] = "flowers:dandelion_yellow",
        ["default:acacia_tree"] = "default:tree",
        ["default:tree"] = "default:aspen_tree",
        ["default:aspen_tree"] = "default:jungletree",
        ["default:jungletree"] = "default:pine_tree",
        ["default:pine_tree"] = "default:acacia_tree",
        ["default:acacia_leaves"] = "default:leaves",
        ["default:leaves"] = "default:aspen_leaves",
        ["default:aspen_leaves"] = "default:jungleleaves",
        ["default:jungleleaves"] = "default:pine_needles",
        ["default:pine_needles"] = "default:acacia_leaves",
        ["default:acacia_bush_leaves"] = "default:bush_leaves",
        ["default:bush_leaves"] = "default:pine_bush_needles",
        ["default:pine_bush_needles"] = "default:acacia_bush_leaves",
        ["default:acacia_bush_stem"] = "default:bush_stem",
        ["default:bush_stem"] = "default:pine_bush_stem",
        ["default:pine_bush_stem"] = "default:acacia_bush_stem",
        ["default:glass"] = "default:sand",
    },
    { --sneak+use
        ["mcl_core:stone"] = "mcl_core:dirt_with_grass",
        ["mcl_core:cobble"] = "mcl_core:dirt_with_grass",
        ["mcl_deepslate:deepslate"] = "mcl_core:podzol",
        ["mcl_deepslate:deepslate_cobbled"] = "mcl_core:podzol",
        ["mcl_core:sand"] = "mcl_core:cobble",
        ["mcl_core:redsand"] = "mcl_core:cobble",
        ["mcl_core:dirt_with_grass"] = "mcl_core:cobble",
        ["mcl_core:dirt"] = "mcl_core:cobble",
        ["mcl_core:podzol"] = "mcl_deepslate:deepslate_cobbled",
        ["mcl_deepslate:tuff"] = "mcl_core:granite",
        ["mcl_core:granite"] = "mcl_core:diorite",
        ["mcl_core:diorite"] = "mcl_core:andesite",
        ["mcl_core:andesite"] = "mcl_deepslate:tuff",
        ["mcl_core:acacialeaves"] = "mcl_core:spruceleaves",
        ["mcl_core:birchleaves"] = "mcl_core:acacialeaves",
        ["mcl_core:darkleaves"] = "mcl_core:birchleaves",
        ["mcl_core:jungleleaves"] = "mcl_core:darkleaves",
        ["mcl_mangrove:mangroveleaves"] = "mcl_core:jungleleaves",
        ["mcl_core:leaves"] = "mcl_mangrove:mangroveleaves",
        ["mcl_core:spruceleaves"] = "mcl_core:leaves",
        ["mcl_core:acaciatree"] = "mcl_core:sprucetree",
        ["mcl_core:birchtree"] = "mcl_core:acaciatree",
        ["mcl_core:darktree"] = "mcl_core:birchtree",
        ["mcl_core:jungletree"] = "mcl_core:darktree",
        ["mcl_mangrove:mangrove_tree"] = "mcl_core:jungletree",
        ["mcl_core:tree"] = "mcl_mangrove:mangrove_tree",
        ["mcl_core:sprucetree"] = "mcl_core:tree",
        ["mcl_nether:netherrack"] = "mcl_end:end_stone",

        ["default:stone"] = "default:dirt_with_grass",
        ["default:cobble"] = "default:dirt_with_grass",
        ["default:desert_stone"] = "default:dry_dirt_with_dry_grass",
        ["default:desert_cobble"] = "default:dry_dirt_with_dry_grass",
        ["default:dry_dirt_with_dry_grass"] = "default:desert_cobble",
        ["default:dirt_with_dry_grass"] = "default:cobble",
        ["default:dirt_with_grass"] = "default:cobble",
        ["default:dirt_with_snow"] = "default:cobble",
        ["default:dirt"] = "default:cobble",
        ["default:dry_dirt"] = "default:desert_cobble",
        ["default:dirt_with_coniferous_litter"] = "default:cobble",
        ["default:dirt_with_rainforest_litter"] = "default:cobble",
        ["default:sand"] = "default:cobble",
        ["default:desert_sand"] = "default:desert_cobble",
        ["default:silver_sand"] = "default:cobble",
        ["default:acacia_tree"] = "default:pine_tree",
        ["default:tree"] = "default:acacia_tree",
        ["default:aspen_tree"] = "default:tree",
        ["default:jungletree"] = "default:aspen_tree",
        ["default:pine_tree"] = "default:jungletree",
        ["default:acacia_leaves"] = "default:pine_needles",
        ["default:leaves"] = "default:acacia_leaves",
        ["default:aspen_leaves"] = "default:leaves",
        ["default:jungleleaves"] = "default:aspen_leaves",
        ["default:pine_needles"] = "default:jungleleaves",
        ["default:acacia_bush_leaves"] = "default:pine_bush_needles",
        ["default:bush_leaves"] = "default:acacia_bush_leaves",
        ["default:pine_bush_needles"] = "default:bush_leaves",
        ["default:acacia_bush_stem"] = "default:pine_bush_stem",
        ["default:bush_stem"] = "default:acacia_bush_stem",
        ["default:pine_bush_stem"] = "default:bush_stem",
    }
}

exchangeclone.stone_action = {
    start_action = function(player, center, range, mode)
        -- Yes, I named the cooldown Phil. His last name is Osophersstone.
        if exchangeclone.check_cooldown(player, "phil") then return end
        exchangeclone.play_ability_sound(player)
        return mode
    end,
    action = function(player, pos, node, mode)
        local new_node = exchangeclone.node_transmutations[mode][node.name]
        if not new_node and mode == 2 then
            new_node = exchangeclone.node_transmutations[1][node.name]
        end
        if new_node then
            if minetest.is_protected(pos, player:get_player_name()) then
                minetest.record_protection_violation(pos, player:get_player_name())
            else
                node.name = new_node
                minetest.swap_node(pos, node)
            end
        end
        return true
    end,
    end_action = function(player, center, range, data)
        exchangeclone.start_cooldown(player, "phil", 0.3)
    end
}

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
        return exchangeclone.range_update(itemstack, player)
    end
    local center = player:get_pos()
    if pointed_thing and pointed_thing.type == "node" then
        center = pointed_thing.under
    end
    if player:get_player_control().sneak then
        local range = tonumber(itemstack:get_meta():get_int("exchangeclone_item_range"))
        exchangeclone.node_radius_action(player, center, range, exchangeclone.stone_action, 2)
    else
        local range = itemstack:get_meta():get_int("exchangeclone_item_range")
        exchangeclone.node_radius_action(player, center, range, exchangeclone.stone_action, 1)
    end
end

minetest.register_tool("exchangeclone:philosophers_stone", {
    description = S("Philosopher's Stone").."\n"..S("Always returned when crafting"),
    inventory_image = "exchangeclone_philosophers_stone.png",
    wield_image = "exchangeclone_philosophers_stone.png",
    exchangeclone_item_range = 0,
    on_use = on_left_click,
    on_place = on_right_click,
    on_secondary_use = on_right_click,
    groups = {philosophers_stone = 1, disable_repair = 1, fire_immune = 1}
})

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