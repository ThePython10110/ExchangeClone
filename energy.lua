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

--[[Energy values mostly taken from https://technicpack.fandom.com/wiki/Alchemical_Math
I had to change some since they weren't as "equivalent" as they were supposed to be.
I also didn't type out the ones with a value of 1, since that's the default.]]

    ["mcl_group"] = {
        sandstone = 3,
        stone_brick = 1,
        wood = 8,
        wood_slab = 4,
        button = 8,
        dye = 8,
        fence_wood = 13,
        wood_stairs = 12,
        flower = 16,
        pane = 0,
        pressure_plate = 16,
        trapdoor = 24,
        fence_gate = 32,
        sapling = 32,
        mushroom = 32,
        tree = 32,
        boat = 40,
        wool = 48,
        door = 12,
        bed = 168,
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
        mossycobble = 9,
        gravel = 3,
        stick = 4,
        flint = 4,
        cactus = 8,
        vine = 8,
        cobweb = 12,
        ladder = 9,
        clay_lump = 16,
        brick = 16,
        charcoal_lump = 32,
        reeds = 32,
        paper = 32,
        sugar = 32,
        obsidian = 64,
        crying_obsidian = 100,
        clay = 64,
        brick_block = 64,
        coal_lump = 128,
        apple = 128,
        gold_nugget = 227,
        iron_ingot = 256,
        lapis = 864,
        diamond = 8192,
    },
    ["mcl_crafting_table"] = {
        crafting_table = 32,
    },
    ["mcl_bows"] = {
        arrow = 3,
        bow = 48,
    },
    ["mcl_fishing"] = {
        fishing_rod = 36,
        fishing_rod_enchanted = 72,
        clownfish_raw = 64,
        fish_cooked = 64,
        fish_raw = 64,
        pufferfish_raw = 64,
        salmon_cooked = 64,
        salmon_raw = 64,
    },
    ["mcl_throwing"] = {
        snowball = 0,
        egg = 32,
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
        melon_seeds = 36,
        melon = 144,
        melon_item = 36,
        cookie = 22,
        pumpkin_seeds = 36,
        wheat_item = 24,
        bread = 72,
        pumpkin = 144,
        pumpkin_face = 144,
        pumpkin_face_light = 144
    },
    ["mcl_cake"] = {
        cake = 411,
    },
    ["mcl_cocoas"] = {
        cocoa_beans = 128,
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
        stair_red_nether_brick = 6,
        slab_brick_block = 32,
        stair_brick_block = 96,
    },
    ["mcl_flowers"] = {
        waterlily = 16,
    },
    ["mcl_mangrove"] = {
    },
    ["mcl_nether"] = {
        nether_brick = 4,
        red_nether_brick = 50,
        nether_wart_item = 24,
        soul_sand = 49,
        soul_soil = 49,
        glowstone_dust = 384,
        glowstone = 1536,
    },
    ["mcl_fences"] = {
    },
    ["mcl_walls"] = {
    },
    ["mcl_end"] = {
        dragon_egg = 139264,
    },
    ["mcl_copper"] = {
        stone_with_copper = 0,
        copper_ingot = 85,
        raw_copper = 85,
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
        bar_flat = 96,
    },
    ["mcl_brewing"] = {
        stand = 0
    },
    ["mcl_cauldrons"] = {
        cauldron = 0
    },
    ["mesecons_button"] = {
    },
    ["mesecons"] = {
        redstone = 64,
    },
    ["mesecons_torch"] = {
        mesecon_torch_on = 68,
    },
    ["mesecons_pressureplates"] = {
        pressure_plate_stone_off = 2,
    },
    ["mesecons_walllever"] = {
        wall_lever_off = 5
    },
    ["mesecons_noteblock"] = {
        noteblock = 128,
    },
    ["mesecons_delayer"] = {
        delayer_off_1 = 203,
    },
    ["mclx_fences"] = {
        nether_brick_fence = 3,
        nether_brick_fence_gate = 6,
        red_nether_brick_fence = 33,
        red_nether_brick_fence_gate = 150,
    },
    ["mcl_tools"] = {
        sword_wood = 21,
        sword_stone = 7,
        shovel_stone = 11,
        pick_stone = 13,
        axe_stone = 13,
        shovel_wood = 18,
        pick_wood = 34,
        axe_wood = 34,
        sword_wood_enchanted = 42,
        sword_stone_enchanted = 14,
        shovel_stone_enchanted = 22,
        pick_stone_enchanted = 26,
        axe_stone_enchanted = 26,
        shovel_wood_enchanted = 36,
        pick_wood_enchanted = 68,
        axe_wood_enchanted = 68,
    },
    ["mcl_potions"] = {
        fermented_spider_eye = 192,
        speckled_melon = 1852,
    },
    ["mcl_mobitems"] = {
        string = 12,
        rotten_flesh = 24,
        slimeball = 24,
        feather = 48,
        porkchop = 64,
        cooked_porkchop = 64,
        beef = 64,
        cooked_beef = 64,
        chicken = 64,
        cooked_chicken = 64,
        leather = 64,
        spider_eye = 128,
        bone = 144,
        gunpowder = 192,
        saddle = 192,
        blaze_powder = 768,
        magma_cream = 768,
        ender_pearl = 1024, --I hate typing "ender" in Lua; it thinks I'm typing "end" and unindents.
        blaze_rod = 1536,
        ghast_tear = 4096,
    },
    ["mcl_torches"] = {
        torch = 9,
    },
    ["mcl_mushrooms"] = {
    },
    ["mcl_bone_meal"] = {
        bone_meal = 48,
    },
    ["mcl_signs"] = {
        wall_sign = 17,
        wall_sign_acaciawood = 17,
        wall_sign_bamboo = 17,
        wall_sign_birchwood = 17,
        wall_sign_crimson_hyphae_wood = 17,
        wall_sign_darkwood = 17,
        wall_sign_junglewood = 17,
        wall_sign_mangrove_wood = 17,
        wall_sign_sprucewood = 17,
        wall_sign_warped_hyphae_wood = 17,
    },
    ["mcl_chests"] = {
        chest = 64
    },
    ["mcl_paintings"] = {
        painting = 96,
    },
    ["mcl_minecarts"] = {
        rail = 96
    },
    ["mcl_books"] = {
        book = 150,
    },
    ["mcl_dispensers"] = {
        dispenser = 119,
    },
    ["mcl_buckets"] = {
        bucket_empty = 768,
        bucket_water = 769,
        bucket_river_water = 769,
        bucket_lava = 896,
        bucket_milk = 832,
        bucket_cod = 896,
        bucket_salmon = 896,
        bucket_tropical_fish = 896,
        bucket_axlotl = 1024,
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

--Wait until all mods are loaded (to make sure all nodes have been registered)
--Easier than making it depend on every single MineClone mod
minetest.register_on_mods_loaded(function()
    -- load energy values into known items
    for modname, itemlist in pairs(energy_values) do
        if minetest.get_modpath(modname) then
            for itemname, energy_value in pairs(itemlist) do
                --minetest.log("Adding energy value ("..energy_value..") for "..modname..":"..itemname)
                local description = minetest.registered_items[itemname].description
                local already_has_value = description:find("Energy Value: (%d+)")
                if already_has_value then
                    description = description:gsub("Energy Value: "..already_has_value, "Energy Value: "..energy_value)
                else
                    description = minetest.registered_items[itemname].description.."\nEnergy Value: "..energy_value
                end
                minetest.override_item(modname..":"..itemname, {
                    description = description,
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