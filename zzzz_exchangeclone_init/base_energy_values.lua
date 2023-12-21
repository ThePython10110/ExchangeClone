if exchangeclone.mcl then
    --[[ Groups are organized so that order matters. Groups that are lower on the
    list will have their energies applied later, making them  higher priority. It's
    unnecessary for single items because order doesn't matter for them. The NO_GROUP
    value is for values that are not in any other group, but adding this means that
    NO items will have their energy calculated by recipes. ]]
    table.insert_all(exchangeclone.group_values, {
        {"flower", 8},
        {"mushroom", 32},
        {"decorated_pot_recipe", 4}, -- has to be 4 because of brick.
        {"music_record", 2048},
    })

    for itemstring, energy_value in pairs({

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
        ["mcl_core:dirt"] = 1,
        ["mcl_core:emerald"] = 4096,
        ["mcl_core:flint"] = 4,
        ["mcl_core:granite"] = 16,
        ["mcl_core:grass"] = 1,
        ["mcl_core:gravel"] = 4,
        ["mcl_core:ice"] = 1,
        ["mcl_core:mycelium"] = 2,
        ["mcl_core:obsidian"] = 64,
        ["mcl_core:redsand"] = 1,
        ["mcl_core:reeds"] = 32,
        ["mcl_core:sand"] = 1,
        ["mcl_core:vine"] = 8,

        ["mcl_crimson:crimson_roots"] = 1,
        ["mcl_crimson:nether_sprouts"] = 1,
        ["mcl_crimson:shroomlight"] = 416,
        ["mcl_crimson:twisting_vines"] = 8,
        ["mcl_crimson:warped_wart_block"] = 216,
        ["mcl_crimson:warped_roots"] = 1,
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

        ["mcl_nether:ancient_debris"] = 12288,
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

        ["useful_green_potatoes:useful_green_potato"] = 256,
    }) do
        exchangeclone.base_energy_values[itemstring] = exchangeclone.base_energy_values[itemstring] or energy_value
    end
    -- TODO: Check after every update
    exchangeclone.mcl_potion_data = exchangeclone.mcl_potion_data or {}
    table.insert_all(exchangeclone.mcl_potion_data, { -- automatically assumes base is awkward potion if not specified
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
    })
else
    exchangeclone.group_values = {
        {"flower", 32},
        --{"dye", 8},
    }

    for itemstring, energy_value in pairs({
        ["bones:bones"] = 4,

        ["bucket:bucket_lava"] = 832,
        ["bucket:bucket_river_water"] = 768,
        ["bucket:bucket_water"] = 768,

        ["default:acacia_bush_leaves"] = 1,
        ["default:acacia_bush_sapling"] = 32,
        ["default:acacia_bush_stem"] = 8,
        ["default:apple"] = 5,
        ["default:blueberries"] = 16,
        ["default:blueberry_bush_leaves"] = 1,
        ["default:blueberry_bush_leaves_with_berries"] = 9,
        ["default:blueberry_bush_sapling"] = 32,
        ["default:bush_leaves"] = 1,
        ["default:bush_sapling"] = 32,
        ["default:bush_stem"] = 8,
        ["default:cactus"] = 8,
        ["default:clay_lump"] = 4,
        ["default:coal_lump"] = 128,
        ["default:cobble"] = 1,
        ["default:coral_brown"] = 8,
        ["default:coral_cyan"] = 8,
        ["default:coral_green"] = 8,
        ["default:coral_orange"] = 8,
        ["default:coral_pink"] = 8,
        ["default:coral_skeleton"] = 8,
        ["default:desert_cobble"] = 1,
        ["default:desert_sand"] = 1,
        ["default:dirt"] = 1,
        ["default:dirt_with_grass"] = 1,
        ["default:dry_dirt"] = 1,
        ["default:dry_dirt_with_dry_grass"] = 1,
        ["default:dry_dirt_with_grass"] = 1,
        ["default:emergent_jungle_sapling"] = 32,
        ["default:flint"] = 4,
        ["default:grass"] = 1,
        ["default:gravel"] = 4,
        ["default:ice"] = 1,
        ["default:large_cactus_seedling"] = 32,
        ["default:mossycobble"] = 32,
        ["default:obsidian"] = 64,
        ["default:papyrus"] = 32,
        ["default:pine_bush_needles"] = 1,
        ["default:pine_bush_sapling"] = 32,
        ["default:pine_bush_stem"] = 8,
        ["default:sand"] = 1,
        ["default:sand_with_kelp"] = 1,
        ["default:silver_sand"] = 1,
        ["default:snow"] = 1,

        ["farming:cotton"] = 12,
        ["farming:cotton_wild"] = 12,
        ["farming:seed_cotton"] = 10,
        ["farming:seed_wheat"] = 16,
        ["farming:wheat"] = 24,

        ["moreores:mithril_ingot"] = 16384,
        ["moreores:silver_ingot"] = 4000,

        ["technic:chromium_ingot"] = 4096,
        ["technic:granite"] = 1,
        ["technic:lead_ingot"] = 256,
        ["technic:marble"] = 1,
        ["technic:sulfur_lump"] = 128,
        ["technic:uranium_ingot"] = 8192,
        ["technic:zinc_ingot"] = 512,

        ["useful_green_potatoes:useful_green_potato"] = 256
    }) do
        exchangeclone.base_energy_values[itemstring] = exchangeclone.base_energy_values[itemstring] or energy_value
    end

end

-- For things that are the same in both games:

for itemstring, energy_value in pairs ({
    ["exchangeclone:alchemical_tome"] = 0,
}) do
    exchangeclone.base_energy_values[itemstring] = energy_value
end

table.insert_all(exchangeclone.group_values, {
    {"tree", 32},
    {"leaves", 1},
    {"sapling", 32},
    {"useless", 0},
    {"exchangeclone_dirt", 1},
})