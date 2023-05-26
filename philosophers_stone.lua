local function show_enchanting(player)
    local player_meta = player:get_meta()
    player_meta:set_int("mcl_enchanting:num_bookshelves", 15)
    player_meta:set_string("mcl_enchanting:table_name", "Enchanting Table")
    mcl_enchanting.show_enchanting_formspec(player)
end

local function call_on_rightclick(itemstack, player, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing and pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if player and not player:get_player_control().sneak then
			local nodedef = minetest.registered_nodes[node.name]
			local on_rightclick = nodedef and nodedef.on_rightclick
			if on_rightclick then
				return on_rightclick(pos, node, player, itemstack, pointed_thing) or itemstack
			end
		end
	end
end

local function round(num)
    if num % 1 < 0.5 then
        return math.floor(num)
    else
        return math.ceil(num)
    end
end

exchangeclone.node_transmutations = {
    { --use
        ["mcl_core:stone"] = "mcl_core:cobble",
        ["mcl_core:cobble"] = "mcl_core:stone",
        ["mcl_core:dirt_with_grass"] = "mcl_core:sand",
        ["mcl_core:podzol"] = "mcl_core:redsand",
        ["mcl_core:dirt"] = "mcl_core:sand",
        ["mcl_core:sand"] = "mcl_core:dirt_with_grass",
        ["mcl_core:redsand"] = "mcl_core:podzol",
        ["mcl_flowers:tallgrass"] = "mcl_core:deadbush",
        ["mcl_nether:netherrack"] = "mcl_core:cobble",
        ["mcl_core:gravel"] = "mcl_core:sandstone",
        ["mcl_core:sandstone"] = "mcl_core:gravel",
        ["mcl_core:redsandstone"] = "mcl_core:gravel",
        ["mcl_farming:pumpkin"] = "mcl_farming:melon",
        ["mcl_farming:melon"] = "mcl_farming:pumpkin",
        ["mcl_core:water_source"] = "mcl_core:ice",
        ["mclx_core:river_water_source"] = "mcl_core:ice",
        ["mcl_core:lava_source"] = "mcl_core:obsidian",
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
        ["mcl_flowers:double_grass"] = "mcl_core:deadbush",
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
        ["mcl_core:bedrock"] = "mcl_core:barrier",
        ["mcl_core:barrier"] = "mcl_core:bedrock",
        ["mcl_end:end_stone"] = "mcl_nether:netherrack",

        ["default:stone"] = "default:cobble",
        ["default:desert_stone"] = "default:desert_cobble",
        ["default:cobble"] = "default:stone",
        ["default:desert_cobble"] = "default:desert_stone",
        ["default:dirt_with_grass"] = "default:sand",
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
        ["default:water_source"] = "default:ice",
        ["default:river_water_source"] = "default:ice",
        ["default:lava_source"] = "default:obsidian",
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
        ["mcl_core:podzol"] = "mcl_deepslate:deepslate_cobbled",
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
        ["mcl_nether:soul_sand"] = "mcl_blackstone:soul_soil",
        ["mcl_blackstone:soul_soil"] = "mcl_nether:soul_sand",

        ["default:stone"] = "default:dirt_with_grass",
        ["default:cobble"] = "default:dirt_with_grass",
        ["default:desert_stone"] = "default:dry_dirt_with_dry_grass",
        ["default:desert_cobble"] = "default:dry_dirt_with_dry_grass",
        ["default:dry_dirt_with_dry_grass"] = "default:desert_cobble",
        ["default:dirt_with_dry_grass"] = "default:cobble",
        ["default:dirt_with_grass"] = "default:cobble",
        ["default:sand"] = "default:cobble",
        ["default:desert_sand"] = "default:desert_cobble",
        ["default:silver_sand"] = "default:cobble",
        ["default:sandstone"] = "default:gravel",
        ["default:desert_sandstone"] = "default:gravel",
        ["default:silver_sandstone"] = "default:gravel",
        ["mcl_core:diorite"] = "mcl_core:andesite",
        ["mcl_core:andesite"] = "mcl_deepslate:tuff",
        ["mcl_deepslate:tuff"] = "mcl_core:granite",
        ["mcl_core:granite"] = "mcl_core:diorite",
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

function exchangeclone.transmute_nodes(player, distance, mode)
    local pos = player:get_pos()
    pos.x = round(pos.x)
    pos.y = math.floor(pos.y) --make sure y is node BELOW player's feet
    pos.z = round(pos.z)
    for x = pos.x-distance, pos.x+distance do
    for y = pos.y-distance, pos.y+distance do
    for z = pos.z-distance, pos.z+distance do
        local new_pos = {x=x,y=y,z=z}
        local node = minetest.get_node(new_pos)
        local new_node = exchangeclone.node_transmutations[mode][node.name]
        if not new_node and mode == 2 then
            new_node = exchangeclone.node_transmutations[1][node.name]
        end
        if new_node then
            if minetest.is_protected(new_pos, player:get_player_name()) then
                minetest.record_protection_violation(new_pos, player:get_player_name())
            else
                node.name = new_node
                minetest.swap_node(new_pos, node)
            end
        end
    end
    end
    end
end

local function on_left_click(itemstack, player, pointed_thing)
    if player:get_player_control().sneak then
        local range = tonumber(itemstack:get_meta():get_int("exchangeclone_stone_range"))
        if range == 0 then range = 5 end
        range = range - 1
        itemstack:get_meta():set_int("exchangeclone_stone_range", range or 0)
        minetest.chat_send_player(player:get_player_name(), "Current Range: "..range)
        return itemstack
    elseif not player:get_player_control().aux1 then
        local new_stack = call_on_rightclick(itemstack, player, pointed_thing)
        if new_stack then
            return new_stack
        end
        local range = itemstack:get_meta():get_int("exchangeclone_stone_range")
        if range == 4 then range = -1 end
        range = range + 1
        itemstack:get_meta():set_int("exchangeclone_stone_range", range or 0)
        minetest.chat_send_player(player:get_player_name(), "Current Range: "..range)
        return itemstack
    elseif exchangeclone.mineclone then
        show_enchanting(player)
    end
end

local function on_right_click(itemstack, player, pointed_thing)
    if player:get_player_control().sneak then
        local range = tonumber(itemstack:get_meta():get_int("exchangeclone_stone_range"))
        exchangeclone.transmute_nodes(player, range, 2)
    elseif not player:get_player_control().aux1 then
        local range = itemstack:get_meta():get_int("exchangeclone_stone_range")
        exchangeclone.transmute_nodes(player, range, 1)
    elseif exchangeclone.mineclone then
        mcl_crafting_table.show_crafting_form(player)
    end
end

minetest.register_tool("exchangeclone:philosophers_stone", {
    description = "Philosopher's Stone",
    inventory_image = "exchangeclone_philosophers_stone.png",
    wield_image = "exchangeclone_philosophers_stone.png",
    exchangeclone_stone_range = 0,
    on_use = on_left_click,
    on_place = on_right_click,
    on_secondary_use = on_right_click,
})

local diamond = "default:diamond"
local corner = "default:tin_ingot"
local side = "default:obsidian"

if exchangeclone.mineclone then
    diamond = "mcl_core:diamond"
    corner = "mcl_nether:glowstone_dust"
    side = "mesecons:redstone"
end

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
        "exchangeclone:philosophers_stone",
        "mcl_core:charcoal_lump",
        "mcl_core:charcoal_lump",
        "mcl_core:charcoal_lump",
        "mcl_core:charcoal_lump"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:charcoal_lump 4",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:coal_lump"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:iron_ingot",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:coal_lump",
        "mcl_core:coal_lump"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:steel_ingot",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:coal_lump",
        "default:coal_lump"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:coal_lump 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:iron_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:coal_lump 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:steel_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_copper:copper_ingot 6",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:copper_ingot 4",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:steel_ingot",
        "default:steel_ingot",
        "default:steel_ingot",
        "default:steel_ingot",
        "default:steel_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:iron_ingot",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_copper:copper_ingot",
        "mcl_copper:copper_ingot",
        "mcl_copper:copper_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:steel_ingot 5",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:copper_ingot",
        "default:copper_ingot",
        "default:copper_ingot",
        "default:copper_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:tin_ingot 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:copper_ingot",
        "default:copper_ingot",
        "default:copper_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:copper_ingot 3",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:tin_ingot",
        "default:tin_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:iron_ingot 8",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:gold_ingot"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:steel_ingot 8",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:gold_ingot"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:gold_ingot",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
        "mcl_core:iron_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:gold_ingot",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:steel_ingot",
        "default:steel_ingot",
        "default:steel_ingot",
        "default:steel_ingot",
        "default:steel_ingot",
        "default:steel_ingot",
        "default:steel_ingot",
        "default:steel_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:mese_crystal",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:gold_ingot",
        "default:gold_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:gold_ingot 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:mese_crystal",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:diamond",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:mese_crystal",
        "default:mese_crystal",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "default:mese_crystal 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "default:diamond"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:emerald",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:gold_ingot",
        "mcl_core:gold_ingot",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:gold_ingot 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:emerald"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:diamond",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:emerald",
        "mcl_core:emerald",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:emerald 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:diamond"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_nether:ancient_debris",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:diamond",
        "mcl_core:diamond",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:diamond 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_nether:ancient_debris"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:diamond 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_nether:netherite_scrap"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:diamond 9",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_nether:netherite_ingot"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_nether:netherite_ingot",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:diamondblock"
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mcl_core:lapis 2",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mesecons_torch:redstoneblock",
        "mesecons_torch:redstoneblock",
        "mesecons_torch:redstoneblock",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mesecons:redstone 27",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:lapis",
        "mcl_core:lapis",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "mesecons:redstone 27",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        "mcl_core:lapis",
        "mcl_core:lapis",
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})