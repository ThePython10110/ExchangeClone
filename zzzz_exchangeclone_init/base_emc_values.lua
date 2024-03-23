-- You can edit these tables any time before minetest.register_on_mods_loaded functions are run.
exchangeclone.group_values = {}
exchangeclone.base_emc_values = {}

if exchangeclone.mcl then
    --[[ Groups are organized so that order matters. Groups that are lower on the
    list will have their energies applied later, making them  higher priority. It's
    unnecessary for single items because order doesn't matter for them. The NO_GROUP
    value is for values that are not in any other group, but adding this means that
    NO items will have their EMC calculated by recipes. ]]
    table.insert_all(exchangeclone.group_values, {
        {"flower", 8},
        {"mushroom", 32},
        {"decorated_pot_recipe", 4}, -- has to be 4 because of brick.
        {"music_record", 2048},
        {"coral_block=1", 64},
        {"coral_block=2", 16},
        {"coral_plant=1", 16},
        {"coral_plant=2", 1},
        {"coral_fan=1", 16},
        {"coral_fan=2", 1},
    })

    for itemstring, emc_value in pairs({

        ["fake_liquids:bucket_fake_lava"] = 832,
        ["fake_liquids:bucket_fake_water"] = 960,

        ["mcl_amethyst:amethyst_shard"] = 32,
        ["mcl_amethyst:calcite"] = 32,

        ["mcl_anvils:anvil_damage_1"] = 5079,
        ["mcl_anvils:anvil_damage_2"] = 2222,

        ["mcl_armor:helmet_chain"] = 1287,
        ["mcl_armor:chestplate_chain"] = 2056,
        ["mcl_armor:leggings_chain"] = 1799,
        ["mcl_armor:boots_chain"] = 1029,

        ["mcl_bamboo:bamboo"] = 2,

        ["mcl_banners:pattern_globe"] = 49152,
        ["mcl_banners:pattern_snout"] = 512,

        ["mcl_beehives:bee_nest"] = 144,

        ["mcl_bells:bell"] = 14336,

        ["mcl_blackstone:basalt"] = 4,
        ["mcl_blackstone:basalt_smooth"] = 4,
        ["mcl_blackstone:blackstone"] = 4,
        ["mcl_blackstone:soul_soil"] = 49,

        ["mcl_bows:crossbow_loaded"] = 298,

        ["mcl_buckets:bucket_cod"] = 832,
        ["mcl_buckets:bucket_lava"] = 832,
        ["mcl_buckets:bucket_river_water"] = 732,
        ["mcl_buckets:bucket_salmon"] = 832,
        ["mcl_buckets:bucket_tropical_fish"] = 832,
        ["mcl_buckets:bucket_water"] = 768,

        ["mcl_cherry_blossom:pink_petals"] = 4,

        ["mcl_cocoas:cocoa_beans"] = 64,

        ["mcl_core:andesite"] = 16,
        ["mcl_core:apple"] = 128,
        ["mcl_core:apple_gold_enchanted"] = 147584,
        ["mcl_core:cactus"] = 8,
        ["mcl_core:charcoal_lump"] = 32,
        ["mcl_core:clay_lump"] = 16,
        ["mcl_core:cobble"] = 1,
        ["mcl_core:cobweb"] = 12,
        ["mcl_core:crying_obsidian"] = 768,
        ["mcl_core:deadbush"] = 8,
        ["mcl_core:diamond"] = 8192,
        ["mcl_core:diorite"] = 16,
        ["mcl_core:emerald"] = 4096,
        ["mcl_core:flint"] = 4,
        ["mcl_core:gold_ingot"] = 2048,
        ["mcl_core:granite"] = 16,
        ["mcl_core:grass"] = 1,
        ["mcl_core:gravel"] = 4,
        ["mcl_core:ice"] = 1,
        ["mcl_core:iron_ingot"] = 256,
        ["mcl_core:mycelium"] = 2,
        ["mcl_core:obsidian"] = 64,
        ["mcl_core:redsand"] = 1,
        ["mcl_core:reeds"] = 32,
        ["mcl_core:sand"] = 1,
        ["mcl_core:vine"] = 8,

        ["mcl_crimson:crimson_roots"] = 1,
        ["mcl_crimson:crimson_nylium"] = 1,
        ["mcl_crimson:nether_sprouts"] = 1,
        ["mcl_crimson:shroomlight"] = 416,
        ["mcl_crimson:twisting_vines"] = 8,
        ["mcl_crimson:warped_wart_block"] = 216,
        ["mcl_crimson:warped_roots"] = 1,
        ["mcl_crimson:warped_nylium"] = 1,
        ["mcl_crimson:weeping_vines"] = 8,

        ["mcl_deepslate:deepslate_cobbled"] = 2,
        ["mcl_deepslate:tuff"] = 4,

        ["mcl_end:chorus_flower"] = 96,
        ["mcl_end:chorus_fruit"] = 192,
        ["mcl_end:dragon_egg"] = 262144,
        ["mcl_end:end_stone"] = 1,

        ["mcl_farming:beetroot_item"] = 64,
        ["mcl_farming:beetroot_seeds"] = 16,
        ["mcl_farming:carrot_item"] = 64,
        ["mcl_farming:melon_item"] = 16,
        ["mcl_farming:potato_item"] = 64,
        ["mcl_farming:potato_item_poison"] = 64,
        ["mcl_farming:pumpkin"] = 144,
        ["mcl_farming:pumpkin_face"] = 144,
        ["mcl_farming:sweet_berry"] = 16,
        ["mcl_farming:wheat_item"] = 24,
        ["mcl_farming:wheat_seeds"] = 16,

        ["mcl_fishing:clownfish_raw"] = 64,
        ["mcl_fishing:fish_raw"] = 64,
        ["mcl_fishing:pufferfish_raw"] = 64,
        ["mcl_fishing:salmon_raw"] = 64,

        ["mcl_flowers:fern"] = 1,
        ["mcl_flowers:tallgrass"] = 1,
        ["mcl_flowers:waterlily"] = 16,
        ["mcl_flowers:wither_rose"] = 128,

        ["mcl_heads:creeper"] = 256,
        ["mcl_heads:skeleton"] = 256,
        ["mcl_heads:steve"] = 256,
        ["mcl_heads:zombie"] = 256,

        ["mcl_honey:honey_bottle"] = 48,
        ["mcl_honey:honeycomb"] = 16,

        ["mcl_lush_caves:cave_vines"] = 16,
        ["mcl_lush_caves:glow_berry"] = 16,
        ["mcl_lush_caves:moss_carpet"] = 8,
        ["mcl_lush_caves:rooted_dirt"] = 5,
        ["mcl_lush_caves:spore_blossom"] = 64,
        ["mcl_lush_caves:azalea"] = 32,
        ["mcl_lush_caves:azalea_flowering"] = 32,

        ["mcl_mangrove:mangrove_roots"] = 4,

        ["mcl_mobitems:beef"] = 64,
        ["mcl_mobitems:blaze_rod"] = 1536,
        ["mcl_mobitems:bone"] = 144,
        ["mcl_mobitems:chicken"] = 64,
        ["mcl_mobitems:diamond_horse_armor"] = 65536,
        ["mcl_mobitems:feather"] = 48,
        ["mcl_mobitems:ghast_tear"] = 4096,
        ["mcl_mobitems:glow_ink_sac"] = 400,
        ["mcl_mobitems:gold_horse_armor"] = 16384,
        ["mcl_mobitems:gunpowder"] = 192,
        ["mcl_mobitems:heart_of_the_sea"] = 32768,
        ["mcl_mobitems:ink_sac"] = 16,
        ["mcl_mobitems:iron_horse_armor"] = 2048,
        ["mcl_mobitems:leather"] = 64,
        ["mcl_mobitems:magma_cream"] = 800,
        ["mcl_mobitems:milk_bucket"] = 784,
        ["mcl_mobitems:mutton"] = 64,
        ["mcl_mobitems:nametag"] = 192,
        ["mcl_mobitems:nautilus_shell"] = 1024,
        ["mcl_mobitems:nether_star"] = 139264,
        ["mcl_mobitems:porkchop"] = 64,
        ["mcl_mobitems:rabbit"] = 64,
        ["mcl_mobitems:rabbit_foot"] = 128,
        ["mcl_mobitems:rabbit_hide"] = 16,
        ["mcl_mobitems:rotten_flesh"] = 32,
        ["mcl_mobitems:saddle"] = 192,
        ["mcl_mobitems:shulker_shell"] = 2048,
        ["mcl_mobitems:slimeball"] = 32,
        ["mcl_mobitems:spider_eye"] = 128,
        ["mcl_mobitems:string"] = 12,

        ["mcl_mobs:nametag"] = 192,

        ["mcl_mud:mud"] = 1,

        ["mcl_nether:netherite_scrap"] = 12288,
        ["mcl_nether:nether_wart_item"] = 24,
        ["mcl_nether:netherrack"] = 1,
        ["mcl_nether:quartz"] = 256,
        ["mcl_nether:soul_sand"] = 49,

        ["mcl_ocean:kelp"] = 16,
        ["mcl_ocean:prismarine_crystals"] = 512,
        ["mcl_ocean:prismarine_shard"] = 256,
        ["mcl_ocean:sea_pickle_1_dead_brain_coral_block"] = 16,
        ["mcl_ocean:seagrass"] = 1,

        ["mcl_pottery_sherds:pot"] = 16,

        ["mcl_sculk:vein"] = 4,
        ["mcl_sculk:sculk"] = 16,
        ["mcl_sculk:catalyst"] = 8040,

        ["mcl_sponges:sponge"] = 128,

        ["mcl_throwing:egg"] = 32,
        ["mcl_throwing:ender_pearl"] = 1024,
        ["mcl_throwing:snowball"] = 1,

        ["meat_blocks:meatball"] = 64,

        ["mesecons:redstone"] = 64,
    }) do
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or emc_value
    end
    -- TODO: Check after every update
    exchangeclone.mcl_potion_data = { -- automatically assumes base is awkward potion if not specified
        {name = "water", bases = {"mcl_potions:glass_bottle"}, no_arrow = true},
        {name = "awkward", bases = {"mcl_potions:water"}, ingredient = "mcl_nether:nether_wart_item", no_arrow = true},
        {name = "mundane", ingredient_cost = 32, no_arrow = true, custom_base_cost = 0},
        {name = "thick", ingredient_cost = 384, no_arrow = true, custom_base_cost = 0},
        {name = "fire_resistance", ingredient = "mcl_mobitems:magma_cream", plus = true},
        {name = "harming", bases = {"mcl_potions:poison", "mcl_potions:healing"}, ingredient = "mcl_potions:fermented_spider_eye", two = true},
        {name = "healing", ingredient = "mcl_potions:speckled_melon", two = true},
        {name = "leaping", ingredient = "mcl_mobitems:rabbit_foot", plus = true, two = true},
        {name = "night_vision", ingredient = "mcl_farming:carrot_item_gold", plus = true},
        {name = "poison", ingredient = "mcl_mobitems:spider_eye", plus = true, two = true},
        {name = "regeneration", ingredient = "mcl_mobitems:ghast_tear", plus = true, two = true},
        {name = "slowness", bases = {"mcl_potions:swiftness", "mcl_potions:leaping"}, ingredient = "mcl_potions:fermented_spider_eye", plus = true, two = true},
        {name = "swiftness", ingredient = "mcl_core:sugar", plus = true, two = true},
        {name = "water_breathing", ingredient = "mcl_fishing:pufferfish_raw", plus = true},
        {name = "invisibility", bases = {"mcl_potions:night_vision"}, ingredient = "mcl_potions:fermented_spider_eye", custom_base_cost = 623, plus = true},
        {name = "withering", ingredient = "mcl_flowers:wither_rose", plus = true, two = true}
    }
elseif exchangeclone.exile then
    -- handled in exchangeclone/base_emc_values.lua
else
    assert(exchangeclone.mtg)
    -- MTG stuff
    table.insert_all(exchangeclone.group_values, {
        {"flower", 32},
    })

    for itemstring, emc_value in pairs({
        ["bones:bones"] = 288,

        ["bucket:bucket_lava"] = 832,
        ["bucket:bucket_river_water"] = 768,
        ["bucket:bucket_water"] = 768,
        ["default:acacia_bush_stem"] = 8,
        ["default:apple"] = 128,
        ["default:blueberries"] = 16,
        ["default:blueberry_bush_leaves_with_berries"] = 17,
        ["default:bush_stem"] = 8,
        ["default:cactus"] = 8,
        ["default:clay_lump"] = 4,
        ["default:coal_lump"] = 128,
        ["default:cobble"] = 1,
        ["default:coral_brown"] = 64,
        ["default:coral_cyan"] = 16,
        ["default:coral_green"] = 16,
        ["default:coral_orange"] = 64,
        ["default:coral_pink"] = 16,
        ["default:coral_skeleton"] = 4,
        ["default:desert_cobble"] = 1,
        ["default:desert_sand"] = 1,
        ["default:flint"] = 4,
        ["default:grass"] = 1,
        ["default:gravel"] = 4,
        ["default:ice"] = 1,
        ["default:large_cactus_seedling"] = 32,
        ["default:mossycobble"] = 9,
        ["default:obsidian"] = 64,
        ["default:papyrus"] = 32,
        ["default:pine_bush_stem"] = 8,
        ["default:sand"] = 1,
        ["default:sand_with_kelp"] = 16,
        ["default:silver_sand"] = 1,
        ["default:snow"] = 1,

        ["farming:cotton"] = 12,
        ["farming:cotton_wild"] = 12,
        ["farming:seed_cotton"] = 10,
        ["farming:seed_wheat"] = 16,
        ["farming:wheat"] = 24,
    }) do
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or emc_value
    end

end

-- For things that are the same in both games:

for itemstring, emc_value in pairs ({
    ["exchangeclone:tome_of_knowledge"] = 0,

    ["moreores:mithril_ingot"] = 16384,
    ["moreores:silver_ingot"] = 4000,
    ["moreores:tin_ingot"] = 320,

    ["technic:chromium_ingot"] = 4096,
    ["technic:granite"] = 1,
    ["technic:lead_ingot"] = 256,
    ["technic:marble"] = 16,
    ["technic:sulfur_lump"] = 128,
    ["technic:uranium_ingot"] = 8192,
    ["technic:zinc_ingot"] = 512,

    ["useful_green_potatoes:useful_green_potato"] = 256
}) do
    exchangeclone.base_emc_values[itemstring] = emc_value
end

if minetest.get_modpath("ethereal") then
    for item, emc in pairs({
        ["bakedclay:grey"] = 16,
        ["bakedclay:orange"] = 16,
        ["bakedclay:red"] = 16,
        ["ethereal:bamboo"] = 18,
        ["ethereal:crystal_spike"] = 8192*4,
        ["ethereal:seaweed"] = 16,
        ["ethereal:banana"] = 64,
        ["ethereal:basandra_bush_stem"] = 16,
        ["ethereal:blue_marble"] = 16,
        ["ethereal:coconut"] = 256,
        ["ethereal:coral2"] = 16,
        ["ethereal:coral3"] = 16,
        ["ethereal:coral4"] = 16,
        ["ethereal:coral5"] = 16,
        ["ethereal:crystalgrass"] = 4,
        ["ethereal:dry_shrub"] = 4,
        ["ethereal:etherium_dust"] = 2048,
        ["ethereal:fern"] = 4,
        ["ethereal:fern_tubers"] = 4,
        ["ethereal:fire_flower"] = 16384,
        ["ethereal:firethorn"] = 1,
        ["ethereal:illumishroom"] = 24,
        ["ethereal:lemon"] = 32,
        ["ethereal:lilac"] = 8,
        ["ethereal:mushroom_pore"] = 32,
        ["ethereal:olive"] = 16,
        ["ethereal:orange"] = 32,
        ["ethereal:pine_nuts"] = 4,
        ["ethereal:snowygrass"] = 4,
        ["ethereal:sponge"] = 128,
        ["ethereal:sponge_wet"] = 128,
        ["ethereal:spore_grass"] = 4,
        ["ethereal:strawberry"] = 32,
        ["ethereal:wild_onion"] = 32,
    }) do
        exchangeclone.base_emc_values[item] = emc
    end

    table.insert_all(exchangeclone.group_values, {
        {"ethereal_fish", 64}
    })
end

if minetest.get_modpath("nether") then
    for item, emc in pairs({
        ["nether:basalt"] = 4,
        ["nether:brick_cracked"] = 1,
        ["nether:rack"] = 1,
        ["nether:rack_deep"] = 1,
        ["nether:fumarole"] = 256,
        ["nether:fumarole_corner"] = 256,
        ["nether:fumarole_slab"] = 256,
        ["nether:geode"] = 64,
        ["nether:glowstone"] = 64,
        ["nether:glowstone_deep"] = 256,
        ["nether:lava_crust"] = 3200,
        ["nether:native_mapgen"] = 1,
    }) do
        exchangeclone.base_emc_values[item] = emc
    end
end

if minetest.get_modpath("mobs") then
    for item, emc in pairs({
        ["mobs:beehive"] = 2048,
        ["mobs:bucket_milk"] = 784,
        ["mobs:chicken_feather"] = 48,
        ["mobs:egg"] = 32,
        ["mobs:hairball"] = 16,
        ["mobs:honey"] = 48,
        ["mobs:leather"] = 64,
        ["mobs:lava_orb"] = 16834,
        ["mobs:rabbit_hide"] = 16,
        ["mobs:rat_cooked"] = 64,
    }) do
        exchangeclone.base_emc_values[item] = emc
    end
    table.insert_all(exchangeclone.group_values, {
        {"food_meat_raw", 64},
    })
end

if minetest.get_modpath("animalia") then
    for item, emc in pairs({
        ["animalia:bucket_guano"] = 832,
        ["animalia:bucket_milk"] = 784,
        ["animalia:feather"] = 48,
        ["animalia:leather"] = 64,
        ["animalia:nametag"] = 192,
        ["animalia:pelt_bear"] = 192,
        ["animalia:saddle"] = 192,
    }) do
        exchangeclone.base_emc_values[item] = emc
    end
    table.insert_all(exchangeclone.group_values, {
        {"food_meat", 64},
        {"food_egg", 32},
    })
end

table.insert_all(exchangeclone.group_values, {
    {"tree", 32},
    {"leaves", 1},
    {"sapling", 32},
    {"useless", 0},
    {"exchangeclone_dirt", 1},
})


-- Moved here so other mods could modify it without dependency issues
exchangeclone.node_transmutations = {
    { --use (mode 1)
        -- Basic nodes
        ["mcl_core:stone"] = "mcl_core:cobble",
        ["mcl_core:cobble"] = "mcl_core:stone",
        ["mcl_core:dirt_with_grass"] = "mcl_core:sand",
        ["mcl_core:dirt"] = "mcl_core:sand",
        ["mcl_core:sand"] = "mcl_core:dirt_with_grass",
        ["mcl_core:sandstone"] = "mcl_core:gravel",
        ["mcl_core:podzol"] = "mcl_core:redsand",
        ["mcl_core:redsand"] = "mcl_core:podzol",
        ["mcl_core:redsandstone"] = "mcl_core:gravel",
        ["mcl_core:glass"] = "mcl_core:sand",
        ["mcl_blackstone:blackstone"] = "mcl_blackstone:basalt",
        ["mcl_blackstone:basalt"] = "mcl_blackstone:blackstone",
        ["mcl_flowers:double_grass"] = "mcl_flowers:fern",
        ["mcl_deepslate:deepslate"] = "mcl_deepslate:deepslate_cobbled",
        ["mcl_deepslate:deepslate_cobbled"] = "mcl_deepslate:deepslate",
        ["mcl_end:end_stone"] = "mcl_nether:netherrack",
        ["mcl_nether:soul_sand"] = "mcl_blackstone:soul_soil",
        ["mcl_blackstone:soul_soil"] = "mcl_nether:soul_sand",

        -- "Frozen" liquids
        ["mcl_core:obsidian"] = "mcl_core:lava_source",
        ["mcl_core:ice"] = "mcl_core:water_source",

        -- Plants
        ["mcl_flowers:tallgrass"] = "mcl_flowers:fern",
        ["mcl_flowers:fern"] = "mcl_flowers:tallgrass",
        ["mcl_farming:pumpkin"] = "mcl_farming:melon",
        ["mcl_farming:melon"] = "mcl_farming:pumpkin",
        ["mcl_flowers:dandelion"] = "mcl_flowers:poppy",
        ["mcl_flowers:poppy"] = "mcl_flowers:dandelion",
        ["mcl_mushrooms:mushroom_brown"] = "mcl_mushrooms:mushroom_red", --technically not plants
        ["mcl_mushrooms:mushroom_red"] = "mcl_mushrooms:mushroom_brown",

        -- Warped/crimson
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

        -- Ores
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

        -- Basic nodes
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
        ["default:sandstone"] = "default:gravel",
        ["default:desert_sandstone"] = "default:gravel",
        ["default:silver_sandstone"] = "default:gravel",
        ["default:gravel"] = "default:sandstone",
        ["default:glass"] = "default:sand",

        -- "Frozen" liquids
        ["default:ice"] = "default:water_source",
        ["default:obsidian"] = "default:lava_source",

        -- Plants
        ["flowers:mushroom_brown"] = "flowers:mushroom_red",
        ["flowers:mushroom_red"] = "flowers:mushroom_brown",
        ["flowers:dandelion_yellow"] = "flowers:rose",
        ["flowers:rose"] = "flowers:dandelion_yellow",
    },
    { --sneak+use (mode 2)
        ["mcl_core:stone"] = "mcl_core:dirt_with_grass",
        ["mcl_core:cobble"] = "mcl_core:dirt_with_grass",
        ["mcl_deepslate:deepslate"] = "mcl_core:podzol",
        ["mcl_deepslate:deepslate_cobbled"] = "mcl_core:podzol",
        ["mcl_core:sand"] = "mcl_core:cobble",
        ["mcl_core:redsand"] = "mcl_core:cobble",
        ["mcl_core:dirt_with_grass"] = "mcl_core:cobble",
        ["mcl_core:dirt"] = "mcl_core:cobble",
        ["mcl_core:podzol"] = "mcl_deepslate:deepslate_cobbled",
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
    }
}

if exchangeclone.mcl then
    exchangeclone.add_transmutation_loop({
        "mcl_core:andesite",
        "mcl_core:diorite",
        "mcl_core:granite",
        "mcl_deepslate:tuff"
    })
end

if exchangeclone.mcl2 then
    exchangeclone.add_transmutation_loop({
        "mcl_core:acacialeaves",
        "mcl_core:birchleaves",
        "mcl_cherry_blossom:cherryleaves",
        "mcl_core:darkleaves",
        "mcl_core:jungleleaves",
        "mcl_mangrove:mangroveleaves",
        "mcl_core:leaves",
        "mcl_core:spruceleaves",
    })
    exchangeclone.add_transmutation_loop({
        "mcl_core:acaciatree",
        "mcl_core:birchtree",
        "mcl_cherry_blossom:cherrytree",
        "mcl_core:darktree",
        "mcl_core:jungletree",
        "mcl_mangrove:mangrovetree",
        "mcl_core:tree",
        "mcl_core:sprucetree",
    })
elseif exchangeclone.mcla then
    exchangeclone.add_transmutation_loop({
        "mcl_lush_caves:azalea_leaves",
        "mcl_lush_caves:azalea_leaves_flowering",
        "mcl_trees:leaves_acacia",
        "mcl_trees:leaves_birch",
        "mcl_trees:leaves_cherry_blossom",
        "mcl_trees:leaves_dark_oak",
        "mcl_trees:leaves_jungle",
        "mcl_trees:leaves_mangrove",
        "mcl_trees:leaves_oak",
        "mcl_trees:leaves_spruce",
    })
    exchangeclone.add_transmutation_loop({
        "mcl_trees:tree_acacia",
        "mcl_trees:tree_birch",
        "mcl_trees:tree_cherry_blossom",
        "mcl_trees:tree_dark_oak",
        "mcl_trees:tree_jungle",
        "mcl_trees:tree_mangrove",
        "mcl_trees:tree_oak",
        "mcl_trees:tree_spruce",
    })
else
    exchangeclone.add_transmutation_loop({
        "default:acacia_leaves",
        "default:leaves",
        "default:aspen_leaves",
        "default:jungleleaves",
        "default:pine_needles"
    })
    exchangeclone.add_transmutation_loop({
        "default:acacia_tree",
        "default:tree",
        "default:aspen_tree",
        "default:jungle_tree",
        "default:pine_tree",
    })
    exchangeclone.add_transmutation_loop({
        "default:acacia_bush_leaves",
        "default:bush_leaves",
        "default:pine_bush_needles"
    })
    exchangeclone.add_transmutation_loop({
        "default:acacia_bush_stem",
        "default:bush_stem",
        "default:pine_bush_stem"
    })
end