-- TODO add more items from minetest_game
-- Names listed are in the order shown in the minetest_game repo
local energy_values = {
    ["group"] = {
    },
    ["default"] = {
        --- Nodes
        -- Stone
        stone = 2,
        cobble = 1,
        stonebrick = 3,
        stone_block = 3,
        mossycobble = 3,

        desert_stone = 3,
        desert_cobble = 3,
        desert_stonebrick = 3,
        desert_stone_block = 3,

        sandstone = 2,
        sandstonebrick = 3,
        sandstone_block = 3,
        desert_sandstone = 2,
        desert_sandstone_brick = 3,
        desert_sandstone_block = 3,
        silver_sandstone = 2,
        silver_sandstone_brick = 3,
        silver_sandstone_block = 3,

        obsidian = 10,
        obsidianbrick = 11,
        obsidian_block = 11,

        -- Soft / Non-Stone,
        dirt = 1,
        dirt_with_grass = 1,
        dirt_with_grass_footsteps = 1,
        dirt_with_dry_grass = 1,
        dirt_with_snow = 1,
        dirt_with_rainforest_litter = 1,
        dirt_with_coniferous_litter = 1,
        dry_dirt = 1,
        dry_dirt_with_dry_grass = 1,

        permafrost = 1,
        permafrost_with_stones = 1,
        permafrost_with_moss = 1,

        sand = 1,
        desert_sand = 1,
        silver_sand = 1,

        gravel = 1,

        clay = 3,

        snow = 1,
        snowblock = 1,
        ice = 1,
        cave_ice = 1,

        -- Trees,
        tree = 2,
        wood = 2,
        leaves = 1,
        sapling = 3,
        apple = 5,

        jungletree = 2,
        junglewood = 2,
        jungleleaves = 1,
        junglesapling = 2,
        emergent_jungle_sapling = 2,

        pine_tree = 2,
        pine_wood = 2,
        pine_needles = 2,
        pine_sapling = 3,

        acacia_tree = 1,
        acacia_wood = 2,
        acacia_leaves = 2,
        acacia_sapling = 3,

        aspen_tree = 2,
        aspen_wood = 2,
        aspen_leaves = 1,
        aspen_sapling = 3,

        -- Ores,
        stone_with_coal = 5,
        coalblock = 36,

        stone_with_iron = 5,
        steelblock = 90,

        stone_with_copper = 5,
        copperblock = 90,

        stone_with_tin = 5,
        tinblock = 90,

        bronzeblock = 63,

        stone_with_gold = 5,
        goldblock = 108,

        stone_with_mese = 5,
        mese = 270,

        stone_with_diamond = 17,
        diamondblock = 198,

        -- Plantlife,
        cactus = 2,
        large_cactus_seedling = 1,

        papyrus = 1,
        dry_shrub = 1,
        junglegrass = 1,

        grass_1 = 1,
        grass_2 = 1,
        grass_3 = 1,
        grass_4 = 1,
        grass_5 = 1,

        dry_grass_1 = 1,
        dry_grass_2 = 1,
        dry_grass_3 = 1,
        dry_grass_4 = 1,
        dry_grass_5 = 1,

        fern_1 = 1,
        fern_2 = 1,
        fern_3 = 1,

        marram_grass_1 = 1,
        marram_grass_2 = 1,
        marram_grass_3 = 1,

        bush_stem = 1,
        bush_leaves = 1,
        bush_sapling = 1,
        acacia_bush_stem = 1,
        acacia_bush_leaves = 1,
        acacia_bush_sapling = 1,
        pine_bush_stem = 1,
        pine_bush_needles = 1,
        pine_bush_sapling = 1,
        blueberry_bush_leaves_with_berries = 1,
        blueberry_bush_leaves = 1,
        blueberry_bush_sapling = 1,

        sand_with_kelp = 1,

        -- Corals,
        coral_green = 2,
        coral_pink = 2,
        coral_cyan = 2,
        coral_brown = 2,
        coral_orange = 2,
        coral_skeleton = 2,

        -- Tools / "Advanced" crafting / Non-"natural",
        bookshelf = 9,

        sign_wall_wood = 4,
        sign_wall_steel = 4,

        ladder_wood = 4,
        ladder_steel = 4,

        fence_wood = 4,
        fence_acacia_wood = 4,
        fence_junglewood = 4,
        fence_pine_wood = 4,
        fence_aspen_wood = 4,

        fence_rail_wood = 4,
        fence_rail_acacia_wood = 4,
        fence_rail_junglewood = 4,
        fence_rail_pine_wood = 4,
        fence_rail_aspen_wood = 4,

        glass = 9,
        obsidian_glass = 10,

        brick = 8,

        meselamp = 15,
        mese_post_light = 4,
        mese_post_light_acacia_wood = 4,
        mese_post_light_junglewood = 4,
        mese_post_light_pine_wood = 4,
        mese_post_light_aspen_wood = 4,

        --- Craft Items
        blueberries = 5,
        book = 4,
        book_written = 5,
        bronze_ingot = 7,
        clay_brick = 6,
        clay_lump = 4,
        coal_lump = 4,
        copper_ingot = 10,
        copper_lump = 4,
        diamond = 22,
        flint = 5,
        gold_ingot = 12,
        gold_lump = 5,
        iron_lump = 5,
        mese_crystal = 30,
        mese_crystal_fragment = 3,
        obsidian_shard = 7,
        paper = 4,
        steel_ingot = 10,
        stick = 3,
        tin_ingot = 10,
        tin_lump = 4,

        --- Furnace
        furnace = 8,

        --- Tools
        -- Picks
        pick_wood = 2,
        pick_stone = 3,
        pick_bronze = 5,
        pick_steel = 5,
        pick_mese = 8,
        pick_diamond = 6,
        -- Shovels
        shovel_wood = 2,
        shovel_stone = 3,
        shovel_bronze = 5,
        shovel_steel = 5,
        shovel_mese = 7,
        shovel_diamond = 6,
        -- Axes
        axe_wood = 2,
        axe_stone = 3,
        axe_bronze = 5,
        axe_steel = 5,
        axe_mese = 8,
        axe_diamond = 6,
        -- Swords
        sword_wood = 2,
        sword_stone = 3,
        sword_bronze = 5,
        sword_steel = 5,
        sword_mese = 8,
        sword_diamond = 6,

        --- Torch
        torch = 3,

        --- Chest
        chest = 2,
        chest_locked = 2,
    },
    ["moreswords"] = {
        sword_ice = 10,
        sword_lava = 10,
        sword_pick = 14,
        sword_smoke = 14,
        sword_teleport = 20,
        sword_water = 5,
    },

--Energy values taken from https://technicpack.fandom.com/wiki/Alchemical_Math
--Didn't type out the ones with a value of 1, since that's the default

    ["mcl_group"] = {
        sandstone = 3,
        stone_brick = 1,
        wood = 8,
        wood_slab = 4,
        button = 2,
        dye = 8,
        fence_wood = 12,
        wood_stairs = 12,
        flower = 16,
        pane = 0,
        pressure_plate = 16,
        trapdoor = 24,
        fence_gate = 32,
    },
    ["mcl_core"] = {
        snow = 0,
        stone_with_coal = 0,
        stone_with_iron = 0,
        stone_with_diamond = 0,
        stone_with_redstone = 0,
        stone_with_lapis = 0,
        stone_with_emerald = 0,
        stone_with_gold = 0,
        gravel = 3,
        stick = 3,
        flint = 4,
        cactus = 8,
        vine = 8,
        cobweb = 12,
        ladder = 14,
        clay_lump = 16,
        brick = 16,
        charcoal_lump = 32,
    },
    ["mcl_crafting_table"] = {
        crafting_table = 32,
    },
    ["mcl_bows"] = {
        arrow = 14,
    },
    ["mcl_fishing"] = {
        fishing_rod = 12,
        fishing_rod_enchanted = 24,
    },
    ["mcl_throwing"] = {
        snowball = 0,
    },
    ["mcl_bamboo"] = {
    },
    ["mcl_furnaces"] = {
        furnace = 8
    },
    ["mcl_farming"] = {
        hoe_stone = 10,
        hoe_stone_enchanted = 20,
        hoe_wood = 24,
        hoe_wood_enchanted = 48,
        wheat_seeds = 16,
        melon_seeds = 16,
        melon = 16,
        cookie = 22,
    },
    ["mcl_stairs"] = {
        slab_redsandstone = 2,
        slab_redsandstonesmooth2 = 2,
        slab_sandstone = 2,
        slab_sandstonesmooth2 = 2,
        slab_acaciatree_bark = 4,
        slab_birchtree_bark = 4,
        slab_darktree_bark = 4,
        slab_jungletree_bark = 4,
        slab_sprucetree_bark = 4,
        slab_tree_bark = 4,
        stair_nether_brick = 6,
        stair_red_nether_brick = 6
    },
    ["mcl_flowers"] = {
        waterlily = 16,
    },
    ["mcl_mangrove"] = {
        mangrove_wood = 8
    },
    ["mcl_nether"] = {
        nether_brick = 3,
        red_nether_brick = 3,
        nether_wart_item = 24,
    },
    ["mcl_fences"] = {
        nether_brick_fence = 4
    },
    ["mcl_walls"] = {
    },
    ["mcl_end"] = {
    },
    ["mcl_copper"] = {
        stone_with_copper = 0
    },
    ["mcl_deepslate"] = {
        deepslate_with_coal = 0,
        deepslate_with_iron = 0,
        deepslate_with_gold = 0,
        deepslate_with_diamond = 0,
        deepslate_with_lapis = 0,
        deepslate_with_redstone = 0,
        deepslate_with_copper = 0,
        deepslate_with_emerald = 0
    },
    ["xpanes"] = {
    },
    ["mcl_brewing"] = {
        stand = 0
    },
    ["mcl_cauldrons"] = {
        cauldron = 0
    },
    ["mesecons_button"] = {
    },
    ["mesecons_pressureplates"] = {
        pressure_plate_stone_off = 2,
    },
    ["mesecons_walllever"] = {
        wall_lever_off = 5
    },
    ["mclx_fences"] = {
        red_nether_brick_fence = 4,
        red_nether_brick_fence_gate = 4,
        nether_brick_fence_gate = 4
    },
    ["mcl_tools"] = {
        sword_wood = 20,
        sword_stone = 6,
        shovel_stone = 9,
        pick_stone = 11,
        axe_stone = 11,
        shovel_wood = 16,
        sword_wood_enchanted = 40,
        sword_stone_enchanted = 12,
        shovel_stone_enchanted = 18,
        pick_stone_enchanted = 22,
        axe_stone_enchanted = 22,
        shovel_wood_enchanted = 32,
    },
    ["mcl_mobitems"] = {
        string = 12,
        rotten_flesh = 24,
        slimeball = 24,
    },
    ["mcl_torches"] = {
        torch = 9,
    },
}

local function get_group_items(groups, allow_duplicates)
	if type(groups) ~= "table" then
		return nil
	end

	allow_duplicates = allow_duplicates or false

	local g_cnt = #groups

	local result = {}
	for i = 1, g_cnt do
		result[groups[i]] = {}
	end

	for name, def in pairs(minetest.registered_nodes) do
		for i = 1, g_cnt do
			local grp = groups[i]
			if def.groups[grp] then
				result[grp][#result[grp]+1] = name
				if allow_duplicates == false then
					break
				end
			end
		end
	end

	return result
end

minetest.register_on_mods_loaded(function()
    -- load energy values into known items
    for modname, itemlist in pairs(energy_values) do
        if minetest.get_modpath(modname) then
            for itemname, energy_value in pairs(itemlist) do
                --minetest.log("Adding energy value ("..energy_value..") for "..modname..":"..itemname)
                minetest.override_item(modname..":"..itemname, {
                    description = minetest.registered_items[modname..":"..itemname].description.."\nEnergy Value: "..energy_value,
                    energy_value = energy_value,
                })
            end
        elseif (modname == "mcl_group" and exchangeclone.mineclone) or (modname == "group" and not exchangeclone.mineclone) then
            local groupnames = {}
            for k,v in pairs(itemlist) do
                groupnames[#groupnames + 1] = k
            end
            local grouped_items = get_group_items(groupnames)
            for groupname, energy_value in pairs(itemlist) do
                for i, item in ipairs(grouped_items[groupname]) do
                        local description = minetest.registered_items[item].description
                        local already_has_value = description:find("Energy Value: (%d+)")
                        if already_has_value then
                            description = description:gsub("Energy Value: "..already_has_value, "Energy Value: "..energy_value)
                        else
                            description = minetest.registered_items[item].description.."\nEnergy Value: "..energy_value
                        end
                    minetest.override_item(item, {
                        description = description,
                        energy_value = energy_value
                    })
                end
            end
        end
    end
end
)