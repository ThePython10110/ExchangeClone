-- WARNING: Do not use aliases; they will be ignored.
exchangeclone.mtg_energy_values = {
    ["exchangeclone"] = {
        orb = 33792,
        element_deconstructor = 67592,
        element_constructor = 92168,
        energy_collector = 23901,
        philosophers_stone = 9984,
    },
    ["beds"] = {
        bed_bottom = 168,
        fancy_bed_bottom = 172,
    },
    ["binoculars"] = {
        binoculars = 796,
    },
    ["boats"] = {
        boat = 40,
    },
    ["bones"] = {
        bones = 4,
    },
    ["bucket"] = {
        bucket_empty = 768,
        bucket_water = 769,
        bucket_river_water = 769,
        bucket_lava = 896,
    },
    ["butterflies"] = {
        butterfly_red = 0,
        butterfly_violet = 0,
        butterfly_white = 0,
    },
    ["carts"] = {
        brakerail = 93,
        cart = 1280,
        powerrail = 313,
        rail = 86,
    },
-- Names listed are in the order shown in the minetest_game repo
    ["default"] = {
        --- Nodes
        -- Stone
        mossycobble = 32,

        sandstone = 4,
        sandstonebrick = 4,
        sandstone_block = 4,
        desert_sandstone = 4,
        desert_sandstone_brick = 4,
        desert_sandstone_block = 4,
        silver_sandstone = 4,
        silver_sandstone_brick = 4,
        silver_sandstone_block = 4,

        obsidian = 64,
        obsidianbrick = 64,
        obsidian_block = 64,

        -- Soft / Non-Stone,
        clay = 64,

        -- Trees,
        apple = 5,
        emergent_jungle_sapling = 32,

        -- Ores,
        stone_with_coal = 0,
        coalblock = 128*9,

        stone_with_iron = 0,
        steelblock = 256*9,

        stone_with_copper = 0,
        copperblock = 320*9,

        stone_with_tin = 0,
        tinblock = 384*9,

        bronzeblock = 327*9,

        stone_with_gold = 0,
        goldblock = 2048*9,

        stone_with_mese = 4096,
        mese = 4096*9,

        stone_with_diamond = 8192,
        diamondblock = 8192*9,

        -- Plantlife,
        cactus = 8,
        large_cactus_seedling = 32,

        papyrus = 32,

        bush_stem = 8,
        bush_leaves = 1,
        bush_sapling = 32,
        acacia_bush_stem = 8,
        acacia_bush_leaves = 1,
        acacia_bush_sapling = 32,
        pine_bush_stem = 8,
        pine_bush_needles = 1,
        pine_bush_sapling = 32,
        blueberry_bush_leaves_with_berries = 9,
        blueberry_bush_leaves = 1,
        blueberry_bush_sapling = 32,

        sand_with_kelp = 32,

        -- Corals,
        coral_green = 8,
        coral_pink = 8,
        coral_cyan = 8,
        coral_brown = 8,
        coral_orange = 8,
        coral_skeleton = 8,

        -- Tools / "Advanced" crafting / Non-"natural",
        bookshelf = 336,

        fence_rail_wood = 2,
        fence_rail_pine_wood = 2,
        fence_rail_junglewood = 2,
        fence_rail_aspen_wood = 2,
        fence_rail_acacia_wood = 2,

        snow = 0.5,
        snowblock = 5,

        sign_wall_wood = 17,
        sign_wall_steel = 513,

        ladder_wood = 5.5,
        ladder_steel = 119,

        obsidian_glass = 7,

        brick = 64,

        meselamp = 4097,
        mese_post_light = 3074,
        mese_post_light_acacia_wood = 3074,
        mese_post_light_junglewood = 3074,
        mese_post_light_pine_wood = 3074,
        mese_post_light_aspen_wood = 3074,

        --- Craft Items
        blueberries = 8,
        book = 96,
        book_written = 96,
        bronze_ingot = 327,
        clay_brick = 16,
        clay_lump = 16,
        coal_lump = 128,
        copper_ingot = 320,
        copper_lump = 320,
        diamond = 8192,
        flint = 4,
        gold_ingot = 2048,
        gold_lump = 2048,
        iron_lump = 256,
        mese_crystal = 4096,
        mese_crystal_fragment = 455,
        obsidian_shard = 7,
        paper = 32,
        steel_ingot = 256,
        stick = 4,
        tin_ingot = 384,
        tin_lump = 384,

        --- Furnace
        furnace = 8,

        --- Tools
        -- Picks
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
        shovel_steel = 264,
        sword_steel = 516,
        pick_steel = 796,
        axe_steel = 796,
        shovel_bronze = 335,
        sword_bronze = 662,
        pick_bronze = 989,
        axe_bronze = 989,
        shovel_diamond = 8200,
        sword_diamond = 16392,
        pick_diamond = 24584,
        axe_diamond = 24584,
        shovel_mese = 4104,
        sword_mese = 8200,
        pick_mese = 12296,
        axe_mese = 12296,

        water_source = 0,
        lava_source = 0,
        river_water_source = 0,

        --- Torch
        torch = 129,

        --- Chest
        chest = 64,
        chest_locked = 320,
    },
    ["doors"] = {
        door_glass = 6,
        door_obsidian_glass = 42,
        door_steel = 1536,
        door_wood = 48,

        gate_wood_closed = 32,
        gate_pine_wood_closed = 32,
        gate_junglewood_closed = 32,
        gate_aspen_wood_closed = 32,
        gate_acacia_wood_closed = 32,

        trapdoor = 24,
        trapdoor_steel = 1024,
    },
    ["farming"] = {
        seed_wheat = 16,
        wheat = 24,
        flour = 96,
        bread = 96,
        straw = 72,
        cotton = 12,
        string = 12,
        cotton_wild = 12,
        seed_cotton = 10,
        hoe_steel = 520,
        hoe_wood = 24,
        hoe_stone = 10,
    },
    ["fire"] = {
        flint_and_steel = 260,
        permanent_flame = 0,
    },
    ["fireflies"] = {
        bug_net = 52,
        firefly = 0, --you don't get to kill them :D
        firefly_bottle = 0,
    },
    ["keys"] = {
        skeleton_key = 2048,
    },
    ["mapping_kit"] = {
        mapping_kit = 629,
    },
    ["screwdriver"] = {
        screwdriver = 260,
    },
    ["moreswords"] = {
        sword_ice = 16394,
        sword_lava = 18184,
        sword_pick = 40976,
        sword_smoke = 16483,
        sword_teleport = 16520,
        sword_water = 1558,
    },
    ["tnt"] = {
        gunpowder = 25,
        tnt_stick = 91,
        tnt = 819,
    },
    ["vessels"] = {
        drinking_glass = 0.5,
        glass_bottle = 0.5,
        glass_fragments = 1,
        shelf = 49.5,
        steel_bottle = 256,
    },
    ["xpanes"] = {
        bar_flat = 96,
        door_steel_bar = 576,
        obsidian_pane_flat = 2.5,
        pane_flat = 0.5,
        trapdoor_steel_bar = 384,
    },
}










--[[Some energy values taken from https://technicpack.fandom.com/wiki/Alchemical_Math
I had to change some since they weren't as "equivalent" as they were supposed to be.
I also didn't type out the ones with a value of 1, since that's the default.]]
exchangeclone.mcl_energy_values = {
    ["exchangeclone"] = {
        element_deconstructor = 67592,
        element_constructor = 92168,
        energy_collector = 23883,
        orb = 33792,
        philosophers_stone = 9984,
    },
    ["mcl_core"] = {
        stonebrickmossy = 9,
        bedrock = 0,
        deadbush = 4,
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
        stone_with_redstone = 0, --ores are worth 0, because the amount sometimes varies (Fortune)
        crying_obsidian = 1000,
        clay = 64,
        brick_block = 64,
        coal_lump = 128,
        stone_with_coal = 0,
        apple = 128,
        gold_nugget = 227,
        iron_ingot = 256,
        stone_with_iron = 0,
        lapis = 864,
        stone_with_lapis = 0,
        emerald = 1024,
        stone_with_emerald = 0,
        gold_ingot = 2048,
        stone_with_gold = 0,
        ironblock = 2304,
        diamond = 8192,
        stone_with_diamond = 0,
        apple_gold = 16512,
        apple_gold_enchanted = 73728,
        bone_block = 432,
        bowl = 24,
        coalblock = 1152,
        dead_bush = 4,
        diamondblock = 73728,
        goldblock = 18432,
        iron_nugget = 28,
        lapisblock = 7776,
        packed_ice = 9,
        slimeblock = 216,
        snow = 0.5,
        glass = 1,
        emeraldblock = 1024*9,
    },
    ["mcl_droppers"] = {
        dropper = 71,
    },
    ["mcl_blast_furnace"] = {
        blast_furnace = 1291,
    },
    ["doc_identifier"] = {
        identifier_solid = 5,
        identifier_liquid = 5,
    },
    ["mcl_beds"] = {
        respawn_anchor = 10608,
    },
    ["mcl_bells"] = {
        bell = 8192,
    },
    ["mcl_enchanting"] = {
        table = 16790,
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
        helmet_netherite = 114688,
        leggings_netherite = 131072,
        chestplate_netherite = 139264,
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
        helmet_netherite_enchanted = 114688*2,
        leggings_netherite_enchanted = 131072*2,
        chestplate_netherite_enchanted = 139264*2,
        elytra = 73728*2,
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
        crossbow = 295,
        crossbow_loaded = 298,
        rocket = 451,
    },
    ["mcl_campfires"] = {
        campfire_lit = 140,
        soul_campfire_lit = 157,
        campfire = 140,
        soul_campfire = 157,
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
    ["mcl_fireworks"] = {
        rocket_1 = 224,
        rocket_2 = 416,
        rocket_3 = 608,
    },
    ["mcl_fire"] = {
        fire_charge = 331,
        flint_and_steel = 260,
    },
    ["mcl_fletching_table"] = {
        fletching_table = 72,
    },
    ["mcl_flowerpots"] = {
        flower_pot = 48,
    },
    ["mcl_fishing"] = {
        fishing_rod = 36,
        fishing_rod_enchanted = 72,
        clownfish_raw = 64,
        fish_cooked = 40,
        fish_raw = 40,
        pufferfish_raw = 64,
        salmon_cooked = 48,
        salmon_raw = 48,
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
    ["mcl_doors"] = {
        acacia_door = 16,
        birch_door = 16,
        dark_oak_door = 16,
        iron_door = 512,
        jungle_door = 16,
        spruce_door = 16,
        wooden_door = 16,
        iron_trapdoor = 768
    },
    ["mcl_lanterns"] = {
        chain = 298,
        lantern_floor = 177,
        soul_lantern_floor = 189,
    },
    ["mcl_lectern"] = {
        lectern = 514,
    },
    ["mcl_lightning_rods"] = {
        rod = 255,
    },
    ["mcl_loom"] = {
        loom = 40,
    },
    ["mcl_maps"] = {
        empty_map = 1120,
        filled_map = 1120,
        filled_map_mcl_skins_base_1B47A57FF_male_crea = 1120,
        filled_map_mcl_skins_base_1EEB592FF_male_crea = 1120,
        filled_map_mcl_skins_base_18D471DFF_male_crea = 1120,
        filled_map_mcl_skins_base_1B47A57FF_female_crea = 1120,
        filled_map_mcl_skins_base_1EEB592FF_female_crea = 1120,
        filled_map_mcl_skins_base_18D471DFF_female_crea = 1120,
        filled_map_mcl_skins_base_1B47A57FF_male_surv = 1120,
        filled_map_mcl_skins_base_1EEB592FF_male_surv = 1120,
        filled_map_mcl_skins_base_18D471DFF_male_surv = 1120,
        filled_map_mcl_skins_base_1B47A57FF_female_surv = 1120,
        filled_map_mcl_skins_base_1EEB592FF_female_surv = 1120,
        filled_map_mcl_skins_base_18D471DFF_female_surv = 1120,
    },
    ["mcl_minecarts"] = {
        activator_rail = 268,
        detector_rail = 267,
        golden_rail = 2059,
        minecart = 1280,
        furnace_minecart = 1288,
        chest_minecart = 1312,
        hopper_minecart = 2624,
        tnt_minecart = 2244,
        rail = 96
    },
    ["mcl_tnt"] = {
        tnt = 964,
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
        beetroot_seeds = 16,
        beetroot_item = 24,
        beetroot_soup = 144,
        carrot_item = 24,
        carrot_item_gold = 1840,
        hay_block = 216,
        potato_item = 24,
        potato_item_baked = 24,
        potato_item_poison = 24,
        melon_seeds = 36,
        melon = 144,
        melon_item = 36,
        cookie = 22,
        pumpkin_seeds = 36,
        wheat_item = 24,
        bread = 72,
        pumpkin = 144,
        pumpkin_face = 144,
        pumpkin_face_light = 153,
        pumpkin_pie = 208,
        sweet_berry = 16,
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
    ["mcl_heads"] = {
        creeper = 256,
        skeleton = 256,
        steve = 256,
        zombie = 256,
        wither_skeleton = 50000,
    },
    ["mcl_hamburger"] = {
        hamburger = 150,
    },
    ["mcl_barrels"] = {
        barrel_closed = 56,
    },
    ["mcl_flowers"] = {
        waterlily = 16,
        wither_rose = 128,
    },
    ["mcl_mangrove"] = {
        mangrove_door = 16,
        mangrove_mud_roots = 2,
    },
    ["mcl_comparators"] = {
        comparator_off_comp = 335,
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
        quartz = 128,
        quartz_ore = 128,
        quartz_block = 512,
        quartz_chiseled = 256,
        quartz_pillar = 512,
        quartz_smooth = 512,
        magma = 4,
        netheriteblock = 663552, --quite a bit.
    },
    ["mcl_observers"] = {
        observer_off = 262,
    },
    ["mcl_ocean"] = {
        brain_coral = 8,
        brain_coral_block = 8,
        brain_coral_fan = 8,
        bubble_coral = 8,
        bubble_coral_block = 8,
        bubble_coral_fan = 8,
        fire_coral = 8,
        fire_coral_block = 8,
        fire_coral_fan = 8,
        horn_coral = 8,
        horn_coral_block = 8,
        horn_coral_fan = 8,
        tube_coral = 8,
        tube_coral_block = 8,
        tube_coral_fan = 8,
        --dead coral worth 1.
        kelp = 32,
        dried_kelp = 32,
        dried_kelp_block = 288,
        prismarine_shard = 2, --crafted with cyan glass
        prismarine = 8,
        prismarine_brick = 18,
        prismarine_dark = 24,
        prismarine_crystals = 2054,
        sea_lantern = 10278,

        -- TODO Add more sea pickles once MineClone does.
        sea_pickle_1_dead_brain_coral_block = 8,
        seagrass = 1,
    },
    ["mcl_portals"] = {
        end_portal_frame = 0,
    },
    ["mcl_fences"] = {
        nether_brick_fence = 3,
    },
    ["mcl_walls"] = {
        brick = 64,
        mossycobble = 9,
        netherbrick = 4,
        rednetherbrick = 50,
        redsandstone = 4,
        sandstone = 4,
        stonebrickmossy = 9,
    },
    ["mcl_end"] = {
        chorus_flower = 32,
        chorus_fruit = 16,
        chorus_fruit_popped = 16,
        crystal = 4293,
        ender_eye = 1792,
        dragon_egg = 139264,
        end_rod = 388,
        purpur_block = 64,
        purpur_pillar = 64,
    },
    ["mcl_experience"] = {
        bottle = 2048,
    },
    ["mcl_raw_ores"] = {
        raw_gold = 2048,
        raw_gold_block = 2048*9,
        raw_iron = 256,
        raw_iron_block = 256*9,
    },
    ["mcl_shields"] = {
        shield = 304,
        shield_black = 596,
        shield_blue = 596,
        shield_brown = 596,
        shield_cyan = 596,
        shield_green = 596,
        shield_grey = 596,
        shield_light_blue = 596,
        shield_lime = 596,
        shield_magenta = 596,
        shield_orange = 596,
        shield_pink = 596,
        shield_purple = 596,
        shield_red = 596,
        shield_silver = 596,
        shield_white = 596,
        shield_yellow = 596,
    },
    ["mcl_smithing_table"] = {
        table = 544,
    },
    ["mcl_smoker"] = {
        smoker = 72,
    },
    ["mcl_sponges"] = {
        sponge = 1024,
        sponge_wet = 1025,
        sponge_wet_river_water = 1025,
    },
    ["mcl_spyglass"] = {
        spyglass = 426,
    },
    ["mcl_copper"] = {
        copper_ingot = 85,
        raw_copper = 85,
        block_raw = 765,
        stone_with_copper = 0,
        block = 765,
        block_exposed = 765,
        block_oxidized = 765,
        block_weathered = 765,
        block_cut = 765,
        block_exposed_cut = 765,
        block_oxidized_cut = 765,
        block_weathered_cut = 765,
        waxed_block = 797,
        waxed_block_exposed = 797,
        waxed_block_oxidized = 797,
        waxed_block_weathered = 797,
        waxed_block_cut = 797,
        waxed_block_exposed_cut = 797,
        waxed_block_oxidized_cut = 797,
        waxed_block_weathered_cut = 797,
    },
    ["mcl_deepslate"] = {
        deepslate_with_coal = 0,
        deepslate_with_copper = 0,
        deepslate_with_diamond = 0,
        deepslate_with_emerald = 0,
        deepslate_with_gold = 0,
        deepslate_with_iron = 0,
        deepslate_with_redstone = 0,
        deepslate_with_lapis = 0,

    },
    ["xpanes"] = {
        bar_flat = 96,
    },
    ["mcl_brewing"] = {
        stand_000 = 1539
    },
    ["mcl_cauldrons"] = {
        cauldron = 1792,
    },
    ["mesecons_button"] = {
        button_stone_off = 1,
    },
    ["mesecons"] = {
        wire_00000000_off = 64,
    },
    ["mesecons_commandblock"] = {
        commandblock_off = 0,
    },
    ["mesecons_lightstone"] = {
        lightstone_off = 1792,
    },
    ["mesecons_pistons"] = {
        piston_normal_off = 348,
        piston_sticky_off = 372
    },
    ["mesecons_solarpanel"] = {
        solar_panel_off = 399,
    },
    ["mesecons_torch"] = {
        mesecon_torch_on = 68,
        redstoneblock = 576,
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
    ["mcl_totems"] = {
        totem = 106496,
    },
    ["mcl_tools"] = {
        shears = 512,
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
        --TODO: Fix dragon's breath (& lingering potions/arrows) once it works like MC.
        dragon_breath = 8.5,
    },
    ["mcl_hoppers"] = {
        hopper = 1344,
    },
    ["mcl_itemframes"] = {
        item_frame = 96,
        glow_item_frame = 352,
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
        chicken = 48,
        cooked_chicken = 48,
        rabbit = 40,
        cooked_rabbit = 40,
        mutton = 48,
        cooked_mutton = 48,
        diamond_horse_armor = 73728,
        gold_horse_armor = 18432,
        iron_horse_armor = 2304,
        heart_of_the_sea = 50000,
        nautilus_shell = 10000,
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
        shulker_shell = 2048,
        ink_sac = 32,
        glow_ink_sac = 256,
        carrot_on_a_stick = 60,
        rabbit_foot = 64,
        rabbit_hide = 16,
        rabbit_stew = 144,
        warped_fungus_on_a_stick = 68,
    },
    ["mcl_mobs"] = {
        nametag = 128,
    },
    ["mcl_mobspawners"] = {
        spawner = 0,
    },
    ["mcl_jukebox"] = {
        jukebox = 8156,
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
        soul_torch = 21,
        nether_gold = 2048,
        blackstone_gilded = 2048,
        quartz_brick = 512,
    },
    ["mcl_torches"] = {
        torch = 9, --would be more, but charcoal kind of ruins it.
    },
    ["mcl_mushrooms"] = {
        mushroom_stew = 88,
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
    ["mcl_crimson"] = {
        crimson_door = 16,
        warped_door = 16,
        twisting_vines = 8,
        weeping_vines = 8,
        shroomlight = 64,
    },
    ["mcl_chests"] = {
        chest = 64,
        ender_chest = 2304,
        trapped_chest = 332,
    },
    ["mcl_paintings"] = {
        painting = 96,
    },
    ["mcl_cartography_table"] = {
        cartography_table = 96,
    },
    ["mcl_books"] = {
        book = 150,
        bookshelf = 498,
        writable_book = 206,
        written_book = 206,
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
    ["mcl_boats"] = {
        boat = 40,
        boat_acacia = 40,
        boat_birch = 40,
        boat_dark_oak = 40,
        boat_jungle = 40,
        boat_mangrove = 40,
        boat_obsidian = 320,
        boat_spruce = 40,
        chest_boat = 104,
        chest_boat_acacia = 104,
        chest_boat_birch = 104,
        chest_boat_dark_oak = 104,
        chest_boat_jungle = 104,
        chest_boat_mangrove = 104,
        chest_boat_spruce = 104,
    },
    ["mcl_compass"] = {
        lodestone = 73736,
    },
    ["mcl_composters"] = {
        composter = 28,
    },
    ["mcl_grindstone"] = {
        grindstone = 24.5,
    },
    ["mcl_stonecutter"] = {
        stonecutter = 259,
    },
    ["mcl_target"] = {
        target_off = 280,
    },
    ["mcl_stairs"] = {
        slab_acaciatree_bark = 16,
        slab_birchtree_bark = 16,
        slab_darktree_bark = 16,
        slab_jungletree_bark = 16,
        slab_sprucetree_bark = 16,
        slab_tree_bark = 16,
        slab_bamboo_stripped = 8,
        slab_copper_cut = 337,
        slab_copper_exposed_cut = 337,
        slab_copper_oxidized_cut = 337,
        slab_copper_weathered_cut = 337,
        slab_waxed_copper_cut = 398,
        slab_waxed_copper_exposed_cut = 398,
        slab_waxed_copper_oxidized_cut = 398,
        slab_waxed_copper_weathered_cut = 398,
        slab_mud_brick = 0.5,
        slab_quartzblock = 256,
        slab_redsandstone = 2,
        slab_sandstone = 2,
        stair_acaciatree_bark = 16*3,
        stair_birchtree_bark = 16*3,
        stair_darktree_bark = 16*3,
        stair_jungletree_bark = 16*3,
        stair_sprucetree_bark = 16*3,
        stair_tree_bark = 16*3,
        stair_bamboo_stripped = 8*3,
        stair_copper_cut = 337*3,
        stair_copper_exposed_cut = 337*3,
        stair_copper_oxidized_cut = 337*3,
        stair_copper_weathered_cut = 337*3,
        stair_waxed_copper_cut = 398*3,
        stair_waxed_copper_exposed_cut = 398*3,
        stair_waxed_copper_oxidized_cut = 398*3,
        stair_waxed_copper_weathered_cut = 398*3,
        stair_mud_brick = 0.5*3,
        stair_quartzblock = 256*3,
        stair_redsandstone = 2*3,
        stair_sandstone = 2*3,
    },
    ["meat_blocks"] = {
        sausage = 64,
        cooked_sausage = 64,
        burnt_sausage = 64,
        burnt_porkchop = 64,
        burnt_beef = 64,
        burnt_chicken = 48,
        burnt_rabbit = 40,
        burnt_mutton = 48,
        burnt_fish = 40,
        burnt_salmon = 48,
        raw_block_sausage = 576,
        raw_block_porkchop = 576,
        raw_block_beef = 576,
        raw_block_chicken = 432,
        raw_block_mutton = 432,
        raw_block_salmon = 432,
        raw_block_rabbit = 360,
        raw_block_fish = 360,
        cooked_block_sausage = 576,
        cooked_block_porkchop = 576,
        cooked_block_beef = 576,
        cooked_block_chicken = 432,
        cooked_block_mutton = 432,
        cooked_block_salmon = 432,
        cooked_block_rabbit = 360,
        cooked_block_fish = 360,
        burnt_block_sausage = 576,
        burnt_block_porkchop = 576,
        burnt_block_beef = 576,
        burnt_block_chicken = 432,
        burnt_block_mutton = 432,
        burnt_block_salmon = 432,
        burnt_block_rabbit = 360,
        burnt_block_fish = 360,
    },
    ["sound_machine"] = {
        sound_machine = 681,
        portable_sound_machine = 681,
    },
    ["fake_liquids"] = {
        solid_water_source = 4,
        solid_useless_bean_liquid_source = 0,
        solid_glue_source = 12,
        solid_river_water_source = 4,
        solid_fake_lava_source = 68,
        solid_lava_source = 131,
        solid_fake_water_source = 195,
        bucket_fake_lava = 833,
        bucket_fake_water = 960,
    },
    ["sticky_things"] = {
        bucket_glue = 797,
        glue_source = 0,
        glue_flowing = 0,
        sticky_block = 100,
    },
    ["ghost_blocks"] = {
        ghostifier = 4104,
    },
    ["lava_sponge"] = {
        lava_sponge = 1032,
        lava_sponge_wet = 1160,
    },
    ["slime_things"] = {
        pressure_plate_slimeblock_off = 432,
        button_slimeblock_off = 24,
    },
    ["small_why_things"] = {
        craftable_barrier = 72,
    }
}

--[[ Groups are organized like this so that order matters. Groups that are lower on the
list will have their energies applied later, making them  higher priority. It's
unnecessary for single items because order doesn't matter for them. The NO_GROUP
value is for values that are not in any other group. Only items that match a group
in the list will have values applied, meaning that NO_GROUP is basically mandatory.

]]

exchangeclone.mtg_group_values = {
    {"NO_GROUP", 1},
    {"tree", 16},
    {"wood", 8},
    {"sapling", 32},
    {"fence", 10},
    {"wool", 48},
    {"dye", 8},
    {"flower", 32},
}

local slabs_and_stairs = {}

exchangeclone.mcl_group_values = {
    {"not_in_creative_inventory", 0},
    {"banner", 292},
    {"sandstone", 4},
    {"wood", 8},
    {"button", 8},
    {"dye", 8},
    {"fence_wood", 13},
    {"flower", 8},
    {"pane", 0.5},
    {"pressure_plate", 16},
    {"trapdoor", 24},
    {"fence_gate", 32},
    {"sapling", 32},
    {"mushroom", 32},
    {"tree", 32},
    {"boat", 40},
    {"wool", 48},
    {"bed", 168},
    {"shulker_box", 4198},
    {"bark", 43},
    {"glass", 2}, --undyed glass is 1
    {"huge_mushroom", 0}, --if you want energy, break it into mushrooms; doesn't always drop.
    {"carpet", 32},
    {"spawn_egg", 0},
    {"useless", 0},
    {"NO_GROUP", 1},
}

exchangeclone.mcl_potion_data = {
    {name = "water", ingredient_cost = 0, custom_base_cost = 0, no_arrow = true},
    {name = "awkward", ingredient_cost = 0, no_arrow = true},
    {name = "fire_resistance", ingredient_cost = 768, plus = true},
    {name = "poison", ingredient_cost = 128, plus = true, two = true},
    {name = "harming", ingredient_cost = 192, custom_base_cost = 52, two = true},
    {name = "healing", ingredient_cost = 1852, two = true},
    {name = "leaping", ingredient_cost = 64, plus = true, two = true},
    {name = "mundane", ingredient_cost = 32, no_arrow = true, custom_base_cost = 0},
    {name = "night_vision", ingredient_cost = 1840, plus = true},
    {name = "regeneration", ingredient_cost = 4096, plus = true, two = true},
    {name = "slowness", ingredient_cost = 192, custom_base_cost = 20, plus = true, two = true},
    {name = "swiftness", ingredient_cost = 32, plus = true, two = true},
    {name = "thick", ingredient_cost = 384, no_arrow = true, custom_base_cost = 0},
    {name = "water_breathing", ingredient_cost = 64, plus = true},
    {name = "invisibility", ingredient_cost = 192, custom_base_cost = 623, plus = true}
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

	for name, def in pairs(minetest.registered_items) do
        in_group = false
		for i = 1, g_cnt do
			local grp = groups[i]
			if def.groups[grp] ~= nil then
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
    local def = minetest.registered_items[itemstring]
    if not def then return end
    if not def.groups then return end
    if not def.description or def.description == "" then return end
    local _, _, mod_name, item_name = itemstring:find("([%d_%l]+):([%d_%l]+)")
    if not (item_name and mod_name) then return end
    if mod_name == "ghost_blocks" then
        energy_value = 0 --I don't know what to do about ghost blocks.
    end
    if exchangeclone.mineclone then
        if exchangeclone.mcl_energy_values[mod_name] then
            energy_value = exchangeclone.mcl_energy_values[mod_name][item_name] or energy_value --override if possible
        end
    else
        if exchangeclone.mtg_energy_values[mod_name] then
            energy_value = exchangeclone.mtg_energy_values[mod_name][item_name] or energy_value --override if possible
        end
    end
    local description = def.description
    local groups = table.copy(def.groups)
    description = description:gsub("Energy Value: ([%d%.]+)", "")
    local existing_energy_value = description:find("Energy Value: ([%d%.]+)")
    if existing_energy_value then
        description = description:gsub("Energy Value: ([%d%.]+)", "Energy Value: "..energy_value)
    else
        if description[#description] ~= "\n" then
            description = description.."\n"
        end
        description = description.."Energy Value: "..(energy_value)
    end
    minetest.override_item(itemstring, {
        description = description,
        energy_value = energy_value,
        groups = groups
    })
    --minetest.log(itemstring.." "..energy_value.." "..reason)
    if mod_name ~= "ghost_blocks" and mod_name ~= "mcl_stairs" and mod_name ~= "stairs" then
        local other_itemstrings = {}
        if exchangeclone.mineclone then
            other_itemstrings = {
                {"mcl_stairs:slab_"..item_name, energy_value/2},
                {"mcl_stairs:stair_"..item_name, energy_value*1.5},
            }
        else
            other_itemstrings = {
                {"stairs:slab_"..item_name, energy_value/2},
                {"stairs:stair_"..item_name, energy_value*1.5},
                {"stairs:stair_inner_"..item_name, energy_value*1.5},
                {"stairs:stair_outer_"..item_name, energy_value*1.5},
            }
        end
        
        for _, info in pairs(other_itemstrings) do
            if minetest.registered_items[info[1]] then
                slabs_and_stairs[#slabs_and_stairs+1] = info
            end
        end
    end
end

local function add_potion_energy(info)
    local base_cost = 2 --cost of water bottle
    --TODO: Change when MineClone does.
    local dragon_breath_cost = 8.5
    base_cost = math.floor(base_cost + (info.ingredient_cost / 3)) --/3 because 3 potions/ingredient
    base_cost = base_cost + (info.custom_base_cost or 8) --8 = 1/3 of nether wart.
    local splash_cost = base_cost + 64
    local lingering_cost = math.floor(base_cost + (dragon_breath_cost / 3))
    exchangeclone.set_item_energy("mcl_potions:"..info.name, base_cost)
    exchangeclone.set_item_energy("mcl_potions:"..info.name.."_splash", splash_cost)
    exchangeclone.set_item_energy("mcl_potions:"..info.name.."_lingering", lingering_cost)
    if not info.no_arrow then
        local arrow_cost = math.floor(lingering_cost / 8 + 3)
        exchangeclone.set_item_energy("mcl_potions:"..info.name.."_arrow", arrow_cost)
    end
    if info.plus then
        local plus_base_cost = base_cost + 21
        local plus_splash_cost = splash_cost + 21
        local plus_lingering_cost = lingering_cost + 21
        local plus_arrow_cost = math.floor(plus_lingering_cost / 8 + 3)
        exchangeclone.set_item_energy("mcl_potions:"..info.name.."_plus", plus_base_cost)
        exchangeclone.set_item_energy("mcl_potions:"..info.name.."_plus_splash", plus_splash_cost)
        exchangeclone.set_item_energy("mcl_potions:"..info.name.."_plus_lingering", plus_lingering_cost)
        exchangeclone.set_item_energy("mcl_potions:"..info.name.."_plus_arrow", plus_arrow_cost)
    end
    if info.two then
        local two_base_cost = base_cost + 21
        local two_splash_cost = splash_cost + 21
        local two_lingering_cost = lingering_cost + 21
        local two_arrow_cost = math.floor(two_lingering_cost / 8 + 3)
        exchangeclone.set_item_energy("mcl_potions:"..info.name.."_2", two_base_cost)
        exchangeclone.set_item_energy("mcl_potions:"..info.name.."_2_splash", two_splash_cost)
        exchangeclone.set_item_energy("mcl_potions:"..info.name.."_2_lingering", two_lingering_cost)
        exchangeclone.set_item_energy("mcl_potions:"..info.name.."_2_arrow", two_arrow_cost)
    end
end

--Wait until all mods are loaded (to make sure all nodes have been registered)
--This is much easier than making it depend on every single MineClone mod.
minetest.register_on_mods_loaded(function()
    if exchangeclone.mineclone then --Set all items to MineClone values
        local groupnames = {}
        for index, group in ipairs(exchangeclone.mcl_group_values) do
            groupnames[#groupnames + 1] = group[1] --Get list of group names
        end
        local grouped_items = get_group_items(groupnames, true, true)
        for index, group in ipairs(exchangeclone.mcl_group_values) do
            for i, item in pairs(grouped_items[group[1]]) do
                exchangeclone.set_item_energy(item, group[2])
            end
        end
        for i = 0, 31 do
            exchangeclone.set_item_energy("mcl_compass:"..i.."_recovery", 443456)
        end
        for i = 0, 31 do
            exchangeclone.set_item_energy("mcl_compass:"..i, 1088)
        end
        exchangeclone.set_item_energy("mcl_compass:compass", 1088)
        for i = 0, 63 do
            exchangeclone.set_item_energy("mcl_clock:clock_"..i, 8256)
        end
        exchangeclone.set_item_energy("mcl_clock:clock", 8256)
        --It's almost like the "compass" and "clock" groups don't exist. I tried using them, but it just didn't work.
        exchangeclone.set_item_energy("mcl_bone_meal:bone_meal", 48)
        --Bone meal just doesn't work either, for some reason.
        for i = 1, 8 do --faster than doing everything individually.
            exchangeclone.set_item_energy("mcl_jukebox:record_"..i, 1024)
        end
        for _, info in ipairs(exchangeclone.mcl_potion_data) do
            add_potion_energy(info)
        end

    else --Set all items to Minetest Game values
        local groupnames = {}
        for index, group in ipairs(exchangeclone.mtg_group_values) do
            groupnames[#groupnames + 1] = group[1] --Get list of group names
        end
        local grouped_items = get_group_items(groupnames, true, true)
        for index, group in ipairs(exchangeclone.mtg_group_values) do
            for i, item in pairs(grouped_items[group[1]]) do
                exchangeclone.set_item_energy(item, group[2])
            end
        end
    end
    
    for _, item in ipairs(slabs_and_stairs) do
        exchangeclone.set_item_energy(item[1], item[2])
    end
end
)