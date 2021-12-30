-- TODO add more items from minetest_game
-- Names listed are in the order shown in the minetest_game repo
local energy_values = {
    ["default"] = {
        --- Nodes
        -- Stone
        stone = 1,
        cobble = 2,
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
        coalblock = 5,

        stone_with_iron = 5,
        steelblock = 5,

        stone_with_copper = 5,
        copperblock = 5,

        stone_with_tin = 5,
        tinblock = 5,

        bronzeblock = 5,

        stone_with_gold = 5,
        goldblock = 5,

        stone_with_mese = 5,
        mese = 5,

        stone_with_diamond = 17,
        diamondblock = 17,

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
        mese_crystal_fragment = 19,
        obsidian_shard = 7,
        paper = 4,
        steel_ingot = 10,
        stick = 3,
        tin_ingot = 10,
        tin_lump = 4,

        --- Furnace
        furnace = 4,

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
}

-- load energy values into known items
for modname, itemlist in pairs(energy_values) do
    if  minetest.get_modpath(modname) then
        for itemname, energy_value in pairs(itemlist) do
            minetest.override_item(modname..":"..itemname, {
                description = minetest.registered_items[modname..":"..itemname].description.."\nEnergy Value: "..energy_value,
                energy_value = energy_value,
            })
        end
    end
end
