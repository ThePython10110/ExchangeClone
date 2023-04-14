-- TODO add more items from minetest_game
-- Names listed are in the order shown in the minetest_game repo
exchangeclone.energy_values = {
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
    ["mcl_core"] = {
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
        crying_obsidian = 1000,
        clay = 64,
        brick_block = 64,
        coal_lump = 128,
        apple = 128,
        gold_nugget = 227,
        iron_ingot = 256,
        lapis = 864,
        emerald = 1024,
        gold_ingot = 2048,
        ironblock = 2304,
        diamond = 8192,
    },
    ["mcl_beds"] = {
        respawn_anchor = 10608,
    },
    ["mcl_bells"] = {
        bell = 8192,
    },
    ["mcl_armor"] = {
        boots_leather = 256,
        helmet_leather = 320,
        leggings_leather = 448,
        chestplate_leather = 512,
        boots_chain = 768,
        helmet_chain = 1024,
        leggings_chain = 1536,
        chestplate_chain = 1792,
        boots_iron = 1024,
        helmet_iron = 1280,
        leggings_iron = 1792,
        chestplate_iron = 2048,
        boots_gold = 8192,
        helmet_gold = 10240,
        leggings_gold = 14336,
        chestplate_gold = 16384,
        boots_diamond = 32768,
        helmet_diamond = 40960,
        leggings_diamond = 57344,
        chestplate_diamond = 65536,
        boots_netherite = 106496,
        helmet_netherite = 147456,
        leggings_netherite = 204800,
        chestplate_netherite = 270336,
        boots_leather_enchanted = 256*2,
        helmet_leather_enchanted = 320*2,
        leggings_leather_enchanted = 448*2,
        chestplate_leather_enchanted = 512*2,
        boots_chain_enchanted = 768*2,
        helmet_chain_enchanted = 1024*2,
        leggings_chain_enchanted = 1536*2,
        chestplate_chain_enchanted = 1792*2,
        boots_iron_enchanted = 1024*2,
        helmet_iron_enchanted = 1280*2,
        leggings_iron_enchanted = 1792*2,
        chestplate_iron_enchanted = 2048*2,
        boots_gold_enchanted = 8192*2,
        helmet_gold_enchanted = 10240*2,
        leggings_gold_enchanted = 14336*2,
        chestplate_gold_enchanted = 16384*2,
        boots_diamond_enchanted = 32768*2,
        helmet_diamond_enchanted = 40960*2,
        leggings_diamond_enchanted = 57344*2,
        chestplate_diamond_enchanted = 65536*2,
        boots_netherite_enchanted = 106496*2,
        helmet_netherite_enchanted = 147456*2,
        leggings_netherite_enchanted = 204800*2,
        chestplate_netherite_enchanted = 270336*2,
        elytra = 73728*4,
    },
    ["mcl_anvils"] = {
        anvil = 7936,
        anvil_damage_1 = 5632,
        anvil_damage_2 = 3328,
    },
    ["mcl_crafting_table"] = {
        crafting_table = 32,
    },
    ["mcl_bows"] = {
        arrow = 3,
        bow = 48,
    },
    ["mcl_amethyst"] = {
        amethyst_shard = 256,
        small_amethyst_bud = 256,
        medium_amethyst_bud = 341,
        large_amethyst_bud = 426,
        amethyst_cluster = 512,
        budding_amethyst_block = 0, --not obtainable in survival
        amethyst_block = 1024,
        tinted_glass = 1025,
        calcite = 128,
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
        snowball = 0.25,
        egg = 32,
        ender_pearl = 1024, --I hate typing "ender" in Lua; it thinks I'm typing "end" and unindents.
    },
    ["mcl_bamboo"] = {
        bamboo = 2,
        scaffolding = 4,
        bamboo_block = 16,
        bamboo_block_stripped = 16,
        bamboo_plank = 8,
        bamboo_mosaic = 8,
        bamboo_door = 16,

    },
    ["mcl_furnaces"] = {
        furnace = 8
    },
    ["mcl_farming"] = {
        hoe_stone = 10,
        hoe_wood = 24,
        hoe_iron = 520,
        hoe_gold = 4104,
        hoe_diamond = 16380,
        hoe_netherite = 90108,
        hoe_stone_enchanted = 10*2,
        hoe_wood_enchanted = 24*2,
        hoe_iron_enchanted = 520*2,
        hoe_gold_enchanted = 4104*2,
        hoe_diamond_enchanted = 16380*2,
        hoe_netherite_enchanted = 90108*2,
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
    ["mcl_beacons"] = {
        beacon = 73925,
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
        slab_bamboo_block = 8,
        stair_bamboo_block = 24,
        slab_bamboo_mosaic = 4,
        slab_bamboo_plank = 4,
        slab_bamboo_stripped = 8,
        stair_bamboo_mosaic = 12,
        stair_bamboo_plank = 12,
        stair_bamboo_stripped = 24

    },
    ["mcl_barrels"] = {
        barrel_closed = 56,
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
        glowstone_dust = 384,
        glowstone = 1536,
        ancient_debris = 16384,
        netherite_scrap = 16384,
        netherite_ingot = 73728,
    },
    ["mcl_fences"] = {
        nether_brick_fence = 3,
    },
    ["mcl_walls"] = {
    },
    ["mcl_end"] = {
        dragon_egg = 139264,
    },
    ["mcl_copper"] = {
        copper_ingot = 85,
        raw_copper = 85,
    },
    ["mcl_deepslate"] = {
    },
    ["xpanes"] = {
        bar_flat = 96,
    },
    ["mcl_brewing"] = {
        stand = 1539
    },
    ["mcl_cauldrons"] = {
        cauldron = 1792,
    },
    ["mesecons_button"] = {
    },
    ["mesecons"] = {
        redstone = 64,
    },
    ["mesecons_torch"] = {
        mesecon_torch_on = 68,
    },
    ["mcl_armor_stand"] = {
        armor_stand = 24.5,
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
        nether_brick_fence_gate = 6,
        red_nether_brick_fence = 33,
        red_nether_brick_fence_gate = 150,
    },
    ["mcl_tools"] = {
        shovel_stone = 9,
        sword_stone = 6,
        pick_stone = 11,
        axe_stone = 11,
        shovel_wood = 16,
        sword_wood = 20,
        pick_wood = 32,
        axe_wood = 32,
        shovel_gold = 2056,
        sword_gold = 5000,
        pick_gold = 6152,
        axe_gold = 6152,
        shovel_iron = 264,
        sword_iron = 516,
        pick_iron = 796,
        axe_iron = 796,
        shovel_diamond = 8200,
        sword_diamond = 16392,
        pick_diamond = 24584,
        axe_diamond = 24584,
        shovel_netherite = 81928,
        sword_netherite = 90120,
        pick_netherite = 98312,
        axe_netherite = 98312,
        shovel_stone_enchanted = 9*2,
        sword_stone_enchanted = 6*2,
        pick_stone_enchanted = 11*2,
        axe_stone_enchanted = 11*2,
        shovel_wood_enchanted = 16*2,
        sword_wood_enchanted = 20*2,
        pick_wood_enchanted = 32*2,
        axe_wood_enchanted = 32*2,
        shovel_gold_enchanted = 2056*2,
        sword_gold_enchanted = 5000*2,
        pick_gold_enchanted = 6152*2,
        axe_gold_enchanted = 6152*2,
        shovel_iron_enchanted = 264*2,
        sword_iron_enchanted = 516*2,
        pick_iron_enchanted = 796*2,
        axe_iron_enchanted = 796*2,
        shovel_diamond_enchanted = 8200*2,
        sword_diamond_enchanted = 16392*2,
        pick_diamond_enchanted = 24584*2,
        axe_diamond_enchanted = 24584*2,
        shovel_netherite_enchanted = 81928*2,
        sword_netherite_enchanted = 90120*2,
        pick_netherite_enchanted = 98312*2,
        axe_netherite_enchanted = 98312*2,
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
        milk_bucket = 832,
        saddle = 192,
        blaze_powder = 768,
        magma_cream = 768,
        blaze_rod = 1536,
        ghast_tear = 4096,
        nether_star = 73728,
    },
    ["mcl_honey"] = {
        honeycomb = 32,
        honey_bottle = 33,
        honey_block = 128,
        honeycomb_block = 128,
    },
    ["mcl_beehives"] = {
        bee_nest = 144,
        beehive = 144,
    },
    ["mcl_blackstone"] = {
        soul_soil = 49,
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
        bucket_cod = 896,
        bucket_salmon = 896,
        bucket_tropical_fish = 896,
        bucket_axolotl = 1024,
    },
}

exchangeclone.mtg_group_values = {

}

exchangeclone.mcl_group_values = {
    {"slab", 0.5},
    {"banner", 292},
    {"sandstone", 3},
    {"stone_brick", 1},
    {"wood", 8},
    {"wood_slab", 4},
    {"button", 8},
    {"dye", 8},
    {"fence_wood", 13},
    {"wood_stairs", 12},
    {"flower", 16},
    {"pane", 3},
    {"pressure_plate", 16},
    {"trapdoor", 24},
    {"fence_gate", 32},
    {"sapling", 32},
    {"mushroom", 32},
    {"tree", 32},
    {"boat", 40},
    {"wool", 48},
    {"door", 12},
    {"bed", 168},
    {"NO_GROUP", 1},
}

local function get_group_items(groups, allow_duplicates, include_no_group)
	if type(groups) ~= "table" then
		return nil
	end

	allow_duplicates = allow_duplicates or false
    include_no_group = include_no_group or false

	local g_cnt = #groups

	local result = {}
	for i = 1, g_cnt do
		result[groups[i]] = {}
	end
    if include_no_group then
        result["NO_GROUP"] = {}
    end
    local in_group = false

	for name, def in pairs(minetest.registered_nodes) do
        in_group = false
		for i = 1, g_cnt do
			local grp = groups[i]
			if def.groups[grp] then
				result[grp][#result[grp]+1] = name
                in_group = true
				if allow_duplicates == false then
					break
				end
			end
		end
        if include_no_group and in_group == false then
            result["NO_GROUP"][#result["NO_GROUP"]+1] = name
        end
	end

	return result
end

function exchangeclone.set_item_energy(itemstring, energy_value)
    local description = ""
    if not pcall(function()
        description = minetest.registered_items[itemstring].description
        local existing_energy_value = description:find("Energy Value: ([%d%.]+)")
        if existing_energy_value then
            minetest.log(itemstring..": old = "..tostring(existing_energy_value)..", new = "..tostring(energy_value))
            description = description:gsub("Energy Value: ([%d%.]+)", "Energy Value: "..energy_value)
            minetest.log(description)
        else
            description = minetest.registered_items[itemstring].description.."\nEnergy Value: "..energy_value
        end
        minetest.override_item(itemstring, {
            description = description,
            energy_value = energy_value,
        })
        return true
    end) then
        minetest.log("error", "Failed to add energy value ("..energy_value..") for "..itemstring)
    else
        --minetest.log("Added energy value ("..energy_value..") for "..itemstring)
    end
end

--Wait until all mods are loaded (to make sure all nodes have been registered)
--This is much easier than making it depend on every single MineClone mod.
minetest.register_on_mods_loaded(function()
    if exchangeclone.mineclone then --Set all group items to MineClone values
        local groupnames = {}
        for index, group in ipairs(exchangeclone.mcl_group_values) do
            groupnames[#groupnames + 1] = group[1] --Get list of group names
        end
        local grouped_items = get_group_items(groupnames, false, true)
        for index, group in ipairs(exchangeclone.mcl_group_values) do
            for i, item in pairs(grouped_items[group[1]]) do
                exchangeclone.set_item_energy(item, group[2])
            end
        end
    else --Set all group items to Minetest Game values
        local groupnames = {}
        for index, group in ipairs(exchangeclone.mtg_group_values) do
            groupnames[#groupnames + 1] = group[0] --Get list of group names
        end
        local grouped_items = get_group_items(groupnames, false, true)
        for index, group in ipairs(exchangeclone.mtg_group_values) do
            for i, item in pairs(grouped_items[group[0]]) do
                exchangeclone.set_item_energy(item, group[1])
            end
        end
    end
    -- load energy values into other items
    for modname, itemlist in pairs(exchangeclone.energy_values) do
        if minetest.get_modpath(modname) then
            for itemname, energy_value in pairs(itemlist) do
                exchangeclone.set_item_energy(modname..":"..itemname, energy_value)                                
            end
        end
    end
end
)